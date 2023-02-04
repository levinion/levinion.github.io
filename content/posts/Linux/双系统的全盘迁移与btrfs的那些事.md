---
title: "双系统的全盘迁移与btrfs的那些事"
created: 2022-10-20 23:36:42

---

## 😂起因

这些天固态硬盘价格疯狂跳水，碰巧我的笔记本储存空间又到了临界值；抵不住诱惑的我终于以不到 400 的价格拿下铠侠 rc20。而我的笔记本又是尴尬的单硬盘位，于是连忙购入硬盘盒开始全盘迁移。

## 🤔简单的情况陈述

我的情况可能比较特殊：Windows 和 ArchLinux 的双系统，其中 arch 更采用了 btrfs 的文件系统，全部储存在一个硬盘当中。虽然不知道 btrfs 的迁移是否相比传统的 ext4 更加简单，但我这次却因为 btrfs 吃尽苦头。这自然不是 btrfs 的原因，归根到底还是因为我对其并不熟悉（没错我就是小白～哼哒）。虽说如此，我在查阅资料的过程中也确实发现，关于btrfs迁移的教程少得可怜，而我也果然在此过程中踩了无数个坑；为了使有需要对btrfs迁移的读者有资料可以参照，也是写这篇文章的动因之一。

## ⚔正戏开演

要对双系统进行全盘迁移，首先有一点是明确的——那就是需要对每个系统进行单独迁移。虽然迁移的顺序无关紧要，但我仍然建议你先迁移 win，以防止 efi 分区的覆盖。

### 🪟Windows 系统迁移

Win 的系统迁移可以说是很简单了。打开[图吧工具箱](http://www.tbtool.cn/index.html)，找到 diskgenuis；或者进入[官网](https://www.diskgenius.cn/)下载。选定硬盘和分区大小进行迁移就好。

迁移完毕，这时可以看到分区：恢复分区、EFI、C盘、D盘……嗯……确认无误后让我们进入下一步骤（当然下面才是我真正想写的东西）。

### 🐧Linux（btrfs）系统迁移

#### 查看硬盘信息

`sudo fdisk -l` 能够清楚查看到所有硬盘的信息。

```bash
Disk /dev/nvme0n1: 931.51 GiB, 1000204886016 bytes, 1953525168 sectors  
Disk model: KIOXIA-EXCERIA G2 SSD                      
Units: sectors of 1 * 512 = 512 bytes  
Sector size (logical/physical): 512 bytes / 512 bytes  
I/O size (minimum/optimal): 512 bytes / 512 bytes  
Disklabel type: gpt  
Disk identifier: 89D3EDE7-1394-43CA-B6E7-4B3FF7916E9C  

Device              Start        End   Sectors   Size Type  
/dev/nvme0n1p1       2048   20973567  20971520    10G Linux swap  
/dev/nvme0n1p2   20973568  986714111 965740544 460.5G Linux files  
/dev/nvme0n1p3  986714112  987762687   1048576   512M EFI System  
/dev/nvme0n1p4  987762688  987795455     32768    16M Microsoft r  
/dev/nvme0n1p5  987795456 1302368255 314572800   150G Microsoft b  
/dev/nvme0n1p6 1302368256 1951477167 649108912 309.5G Microsoft b  
/dev/nvme0n1p7 1951477760 1953525134   2047375 999.7M Windows rec
```

> 这里出于演示，只展示了一个硬盘（<s>因为我只连了一个硬盘</s>）。需要格外注意硬盘的标识，以免出现不小心把需要迁移的硬盘给格了的惨况。

#### 分区

我所采用的分区方式参照 [archlinux 简明指南](https://arch.icekylin.online/) ，采取了上面所展示的分区方式。也就是说，分了内存的 60% 给 swap，其余全部分给根目录。分区操作使用 `sudo cfdisk /dev/nvme0n1p2` 。

> 为使示范代码更具体，下文将以上面的分区信息为例。你所需要关注的只有 swap、Linux File 以及 EFI 所在的卷，此处分别为 /dev/nvme0n1p1,/dev/nvme0n1p2 和 /dev/nvme0n1p3。以下命令若无权限请自行添加 sudo 或在 root 下运行。

分别选择新加卷的大小和类型，同样在进行仔细检查后用 \[Write\] 确认写入并 \[Quit\] 退出。

#### 格式化分区

##### 格式化 swap 分区

```bash
mkswap /dev/nvme0n1p1
```

##### 格式化 btrfs 分区

```bash
mkfs.btrfs -L iArch /dev/nvme0n1p2
```

> 其中，-L 可指定你所喜欢的分区标签。

##### 创建子卷

```bash
# 首先挂载btrfs分区
mount -t btrfs -o compress=zstd /dev/nvme0n1p2 /mnt

# 然后创建子卷
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home

# 最后卸载/mnt以进行下一步操作
umount /mnt
```

#### 同步

为了无损迁移数据，使用 `rsync` 同步数据。

```bash
# 挂载分区
mount /dev/nvme0n1p2 /mnt
```

> 此处不能使用 btrfs 的挂载方式，否则无法显示子卷。btrfs 文件系统需要分别同步子卷，否则就会出现文件被隐藏的情况（我在迁移过程中所遇到的最大的坑！都是血泪）。

```bash
# 同步 @ 子卷
rsync -aAXv /* /mnt/@ --exclude={"/home/*","/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found","/boot"}

# 同步 @home 子卷
rsync -aAxv /home/* /mnt/@home

# 卸载
mount /mnt
```

#### 挂载

```bash
# 挂载 / 目录
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme0n1p2 /mnt
# 挂载 /home 目录
mount -t btrfs -o subbol=/@home,compress=zstd /dev/nvme0n1p2 /mnt/home
# 挂载 efi 目录
mount /dev/nvme0n1p3 /mnt/boot/efi
# 挂载 swap 分区
swapon /dev/nvme0n1p1

# 挂载完毕后，生成 fstab 文件
genfstab -U /mnt > /mnt/etc/fstab

# 卸载
umount -R /mnt
```

### 重建引导

重建引导其实可以参考我的另一篇文章 [Grub引导恢复历险](https://levinion.github.io/posts/grub%E5%BC%95%E5%AF%BC%E6%81%A2%E5%A4%8D%E5%8E%86%E9%99%A9/) ，对那些不想跳转到另一篇文章的读者，我在下面简要列出了关键步骤。

> 其实只是把那篇文章的命令抄过来……

```bash
# 挂载根目录
mount -t btrfs -o subvol=/@,compress=zstd /dev/nvme0n1p2 /mnt

# 挂载家目录
mount -t btrfs -o subvol=/@home,compress=zstd /dev/nvme0n1p2 /mnt/home

# 挂载 efi 目录
mount /dev/nvme0n1p1 /mnt/boot/efi

# 切换系统环境
arch-chroot /mnt

# （重新）安装相关的包
pacman -S grub efibootmgr os-prober

# 安装 GRUB 到 EFI 分区
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCH

# 生成 grub 配置文件
grub-mkconfig -o /boot/grub/grub.cfg

exit # 退出

umount -R /mnt #卸载分区

reboot #重启

# 若无Windows引导，在进入系统后……
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 🥂小结

至此全部工作告一段落。Linux 能够使用 rsync 进行迁移的根本原因在于 Unix “一切皆文件” 的理念；虽说如此，Linux 的正确迁移需要对其文件系统的结构有一个全局性的认识，相比 Windows 借助第三方工具进行一键迁移确实略显复杂。但是，正是通过这种复杂我们才能从中学到有价值的东西；Windows 那种黑盒一般的迁移方式除了让人感到方便，又能让人从中学到什么呢？

> <s>不过果然在学习面前，这种时候方便才是更重要的！</s>
