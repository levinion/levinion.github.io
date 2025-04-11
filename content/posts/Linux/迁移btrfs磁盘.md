---
title: 迁移btrfs磁盘
created: 2025-04-11 14:02:48
---
## 前言

因为许久不使用Windows，因此决定腾出空间，并且将ArchLinux系统迁移到这个硬盘上。原本和新的文件系统均使用btrfs，因此使用btrfs快照进行迁移，特此记录一下。

## 准备

原来文件系统结构如下：

```shell
nvme1n1     259:1    0   921G  0 disk
├─nvme1n1p1 259:2    0     1G  0 part /boot
├─nvme1n1p2 259:3    0    64G  0 part [SWAP]
└─nvme1n1p3 259:4    0   856G  0 part /home
                                      /
```

### 格式化Windows磁盘

首先使用cfdisk清空原来Windows所在磁盘（在/dev/nvme0n1），Delete掉全部分区并Write即可：

```shell
sudo cfdisk /dev/nvme0n1
```

### 初始化

如果只是需要添加新磁盘，使用`btrfs device add`命令即可：

```shell
sudo btrfs device add /dev/nvme0n1 /mnt/
```

使用这种方法可以简单地扩容，btrfs在底层将两个磁盘抽象为一个大的磁盘。但缺点在于，无法控制数据的位置，特别是当两个磁盘速度相差较大时会影响文件系统性能，因此最好再单独创建一个文件系统。

先创建efi、swap以及root，以便后续更改挂载点。

```shell
sudo cfdisk /dev/nvme0n1
```

```shell
nvme0n1     259:1    0   1.8T  0 disk
├─nvme0n1p1 259:2    0     1G  0 part
├─nvme0n1p2 259:3    0    64G  0 part
└─nvme0n1p3 259:4    0   1.8T  0 part
```

然后建立文件系统：

```shell
# efi
sudo mkfs.fat -F32 /dev/nvme0n1p1
# swap
sudo mkswap /dev/nvme0n1p2
# root
sudo mkfs.btrfs -fL arch /dev/nvme0n1p3
```

## 迁移

### 创建和发送快照

我们需要使用`send`和`receive`将快照发送到新创建的btrfs文件系统中，因此需要先创建快照。由于`send`命令的前提是快照必须是只读快照，因此需要在发送完毕后利用只读快照生成读写快照。

```shell
# 创建/@home快照
sudo btrfs subvolume snapshot -r /home /@home_old
# 创建/@快照
sudo btrfs subvolume snapshot -r / /@root_old
```

使用`send`和`receive`发送快照：

```shell
# mount目标分区到/mnt
sudo mount -t btrfs -o compress=zstd /dev/nvme0n1p3 /mnt/
# 发送@home
sudo btrfs send /@home_old | sudo btrfs receive /mnt/
# 发送@
sudo btrfs send /@root_old | sudo btrfs receive /mnt/
```

等待一段时间，如果子卷比较大，时间可能会很长。

然后创建读写快照，并删除作为中介的可读快照。

```shell
sudo btrfs subvolume snapshot /mnt/@home_old /mnt/@home
sudo btrfs subvolume snapshot /mnt/@root_old /mnt/@

sudo btrfs subvolume delete /@home_old
sudo btrfs subvolume delete /@root_old
sudo btrfs subvolume delete /mnt/@home_old
sudo btrfs subvolume delete /mnt/@root_old
```

### archiso

如果只是更改`home`分区，直接修改`/etc/fstab`即可。如果涉及到`root`，就需要上archiso重新挂载。

进入archiso后，重新mount：

```shell
# 挂载efi
mkdir /mnt/boot
mount /dev/nvme1n1p1 /mnt/boot
# 挂载root
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme1n1p3 /mnt
# 挂载home
mkdir /home
mount -t btrfs -o subvol=/@home,compress=zstd /dev/nvme1n1p3 /mnt/home
# 启用swap
swapon /dev/nvme1n1p2
```

由于现在efi为空，所以需要重新安装grub。为了避免旧的efi干扰，先使用`cfdisk`删掉旧的efi分区和swap分区。为保险起见，先不要动旧的root，以免不慎导致数据丢失。

安装grub前先进入chroot环境：

```shell
arch-chroot /mnt
```

然后安装grub：

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="GRUB"

grub-mkconfig -o /boot/grub/grub.cfg
```

此时需要重新安装内核：

```shell
pacman -S linux-zen # 或linux
```

重新mkconfig下：

```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

别忘记生成fstab：

```shell
genfstab -U / > /etc/fstab
```

之后重启即可。

## ext4

之后就是后话了。在迁移后，可以将旧的linux磁盘格式化，作为数据磁盘。为了性能相对高点，选择ext4。

格式化：

```shell
sudo mkfs.ext4 /dev/nvme1n1
```

挂载：

```shell
sudo mount /dev/nvme1n1 /media/d/
```

此时该文件夹需要root权限，user无法写入。由于ext不支持uid、gid等标志，因此需要使用`chown`修改权限：

```shell
sudo chown 1000:1000 /media/d/
```

修改fstab使其自动挂载（也可以使用genfstab）：

```shell
# /dev/nvme1n1
UUID=9c012ac6-ba03-4831-88a7-3128df7b828e /media/d ext4 rw,relatime 0 2
```