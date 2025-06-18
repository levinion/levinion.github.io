---
title: 迁移btrfs磁盘
created: 2025-04-11 14:02:48
---
## 前言

因为许久不使用 Windows，因此决定腾出空间，并且将 ArchLinux 系统迁移到这个硬盘上。原本和新的文件系统均使用 btrfs，因此使用 btrfs 快照进行迁移，特此记录一下。

## 准备

原来文件系统结构如下：

```shell
nvme1n1     259:1    0   921G  0 disk
├─nvme1n1p1 259:2    0     1G  0 part /boot
├─nvme1n1p2 259:3    0    64G  0 part [SWAP]
└─nvme1n1p3 259:4    0   856G  0 part /home
                                      /
```

### 格式化 Windows 磁盘

首先使用 cfdisk 清空原来 Windows 所在磁盘（在/dev/nvme0n1），Delete 掉全部分区并 Write 即可：

```shell
sudo cfdisk /dev/nvme0n1
```

### 初始化

如果只是需要添加新磁盘，使用 `btrfs device add` 命令即可：

```shell
sudo btrfs device add /dev/nvme0n1 /mnt/
```

使用这种方法可以简单地扩容，btrfs 在底层将两个磁盘抽象为一个大的磁盘。但缺点在于，无法控制数据的位置，特别是当两个磁盘速度相差较大时会影响文件系统性能，因此最好再单独创建一个文件系统。

先创建 efi、swap 以及 root，以便后续更改挂载点。

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

我们需要使用 `send` 和 `receive` 将快照发送到新创建的 btrfs 文件系统中，因此需要先创建快照。由于 `send` 命令的前提是快照必须是只读快照，因此需要在发送完毕后利用只读快照生成读写快照。

```shell
# 创建/@home快照
sudo btrfs subvolume snapshot -r /home /@home_old
# 创建/@快照
sudo btrfs subvolume snapshot -r / /@root_old
```

使用 `send` 和 `receive` 发送快照：

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

### 修改自动挂载的磁盘分区

如果只是更改 `home` 分区，直接修改 `/etc/fstab` 即可。如果涉及到 `root`，修改fstab是没用的。这是因为要加载哪个磁盘分区作为root是由bootloader决定的。当bootloader读到root分区所在磁盘，启动内核，内核才能读取fstab并加载其他分区。

此处有两种方法，一种是直接修改bootloader中内核的启动参数。如果使用grub，则在`/boot/grub/grub.cfg`中有以下启动项：

```shell
menuentry 'Arch Linux, with Linux linux' --class arch --class gnu-linux --class gnu --class os $menuentry_id_option 'gnulinux-linux-advanced-ff608a41-1d92-4e49-9206-412b75e807f8' {
    load_video
    set gfxpayload=keep
    insmod gzio
    insmod part_gpt
    insmod fat
    search --no-floppy --fs-uuid --set=root 1574-9ED5
    echo    'Loading Linux linux ...'
    linux   /vmlinuz-linux root=UUID=ff608a41-1d92-4e49-9206-412b75e807f8 rw rootflags=subvol=@  loglevel=5 nowatchdog
    echo    'Loading initial ramdisk ...'
    initrd  /amd-ucode.img /initramfs-linux.img
}
```

其中，`linux   /vmlinuz-linux root=UUID=ff608a41-1d92-4e49-9206-412b75e807f8 rw rootflags=subvol=@  loglevel=5 nowatchdog`就是内核的启动参数，它由`/etc/default/grub`中的`GRUB_CMDLINE_LINUX_DEFAULT`或`GRUB_CMDLINE_LINUX`控制，并在`grub-mkconfig`被调用时自动生成。

我们需要将参数中的UUID替换成（新的）root分区的uuid。这可以通过`sudo btrfs filesystem show`得到。

注意，在重新启动之前不要运行`grub-mkconfig`，因为这会覆盖掉之前做过的改动。当重启并确认分区挂载无误后，再去更新grub配置文件。

另外，如果你的/boot分区不在根分区之下（也就是说不在btrfs文件系统中），它就无法同步过去。因此，需要单独将原来/boot分区的所有内容拷贝到新的分区当中。

> 为了方便快照回滚，最好还是将/boot分区和efi分开，将/boot放到root之下，从而使得内核版本能够与快照的状态保持一致。
### archiso

> 如果做过上面的步骤，可以跳过这步

另一种就是上 archiso 重新挂载，然后更新grub配置文件。

进入 archiso 后，重新 mount：

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

由于现在 efi 为空，所以需要重新安装 grub。为了避免旧的 efi 干扰，先使用 `cfdisk` 删掉旧的 efi 分区和 swap 分区。为保险起见，先不要动旧的 root，以免不慎导致数据丢失。

安装 grub 前先进入 chroot 环境：

```shell
arch-chroot /mnt
```

然后安装 grub：

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="GRUB"

grub-mkconfig -o /boot/grub/grub.cfg
```

此时需要重新安装内核：

```shell
pacman -S linux-zen # 或linux
```

重新 mkconfig 下：

```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

别忘记生成 fstab：

```shell
genfstab -U / > /etc/fstab
```

之后重启即可。

## ext4

之后就是后话了。在迁移后，可以将旧的 Linux 磁盘格式化，作为数据磁盘。为了性能相对高点，选择 ext4。

格式化：

```shell
sudo mkfs.ext4 /dev/nvme1n1
```

挂载：

```shell
sudo mount /dev/nvme1n1 /media/d/
```

此时该文件夹需要 root 权限，user 无法写入。由于 ext 不支持 uid、gid 等标志，因此需要使用 `chown` 修改权限：

```shell
sudo chown 1000:1000 /media/d/
```

修改 fstab 使其自动挂载（也可以使用 genfstab）：

```shell
# /dev/nvme1n1
UUID=9c012ac6-ba03-4831-88a7-3128df7b828e /media/d ext4 rw,relatime 0 2
```

## 其他

据仙子所言，可以使用一种非常简便的方式进行磁盘迁移：

```shell
btrfs device add <新磁盘>
btrfs device delete <旧磁盘>
```

通过这种方式可以在不进入到 archiso 的前提下完成磁盘迁移，并且无需改动 fstab 和 grub，因为磁盘的 uuid 没有发生改变。

虽然我还没有验证这种方式，但应当是可行的。