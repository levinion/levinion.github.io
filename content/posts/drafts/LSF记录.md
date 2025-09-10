---
title: LSF记录
created: 2025-09-07 15:39:33
---
LFS，即「Linux From Scratch」。用书中的一句话介绍：

> LFS 项目存在的一项重要原因是，它能够帮助您学习 Linux 系统的内部是如何运作的

对于一个Linux用户来说，了解Linux发行版的内部工作机制总是好的。

让我们从这个文档开始：[lfs-systemd-中文翻译版](https://lfs.xry111.site/zh_CN/12.4-systemd/)。

## 准备宿主系统

### 创建虚拟机

为了安装LFS，需要先准备一个宿主系统（必须是Linux）。这个宿主系统目的是编译和准备LFS所需要用到的文件和包，相当于一个发行版的live系统。

当然这可以使用现有的Linux系统，但最好还是在虚拟机中重新创建一个新系统作为宿主系统。之后我们会为LFS单独进行分区。

对此先使用qemu创建一个虚拟机，Makefile如下：

```shell
run:
	qemu-system-x86_64 -enable-kvm \
		-machine q35 \
    -drive if=pflash,format=raw,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
    -cpu host \
    -smp 8 \
    -m 16G \
    -net nic \
    -net user,hostfwd=tcp::2222-:22 \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -serial none \
    -parallel none \
		-drive file=./lfs.qcow2,format=qcow2
		-drive file=./archlinux-2025.09.06-x86_64.iso,format=raw

.PHONY: run
```

为其分配一个100G的虚拟硬盘：

```shell
qemu-img create -f qcow2 lfs.qcow2 100G 
```

由于需要编译软件包，尽可能多地分配cpu和内存。此处使用archlinux作为宿主系统。虚拟机安装过程就略去不谈。

为了一个更好的安装体验，可以先开启sshd（别忘记安装openssh）：

```shell
systemctl enable --now sshd
```

### 检查依赖

为此，LFS提供了一个检查需要用到的宿主机依赖的脚本：[hostreqs](https://lfs.xry111.site/zh_CN/12.4-systemd/chapter02/hostreqs.html)

如果正常安装了基础archlinux系统，依赖已经满足：

```shell
lfs@archlinux ~> ./version-check.sh 
OK:    Coreutils 9.7    >= 8.1
OK:    Bash      5.3.3  >= 3.2
OK:    Binutils  2.45.0 >= 2.13.1
OK:    Bison     3.8.2  >= 2.7
OK:    Diffutils 3.12   >= 2.8.1
OK:    Findutils 4.10.0 >= 4.2.31
OK:    Gawk      5.3.2  >= 4.0.1
OK:    GCC       15.2.1 >= 5.4
OK:    GCC (C++) 15.2.1 >= 5.4
OK:    Grep      3.12   >= 2.5.1a
OK:    Gzip      1.14   >= 1.3.12
OK:    M4        1.4.20 >= 1.4.10
OK:    Make      4.4.1  >= 4.0
OK:    Patch     2.8    >= 2.5.4
OK:    Perl      5.42.0 >= 5.8.8
OK:    Python    3.13.7 >= 3.4
OK:    Sed       4.9    >= 4.1.5
OK:    Tar       1.35   >= 1.22
OK:    Texinfo   7.2    >= 5.0
OK:    Xz        5.8.1  >= 5.0.0
OK:    Linux Kernel 6.16.5 >= 5.4
OK:    Linux Kernel supports UNIX 98 PTY
Aliases:
OK:    awk  is GNU
OK:    yacc is Bison
OK:    sh   is Bash
Compiler check:
OK:    g++ works
OK: nproc reports 16 logical cores are available
```

### 分区

分区和一般Linux发行版一样，可以按照自己喜欢的方式来。我倾向于以下的结构：

- /efi：fat32文件系统，用来存放grub的efi文件，因此理论上只需要1MB，但是这里还是保守点，为其分配100MB
- /：根目录，这里我推荐使用btrfs进行管理。分别建立`/@`和/`@home`两个子卷，挂载为根目录和家目录，在`/@`下方创建一个boot文件夹作为`/boot`。可以建立一个/@snapshots子卷存放快照，但这边就不做了。
- swap：交换分区，在物理机上是推荐设置的，但此处省略。

之前我为虚拟机分配了100G磁盘有些不够用（被我全分给宿主机了），因此对其进行扩容。好在qcow2扩容十分方便：

```shell
qemu-img resize lfs.qcow2 200G
```

分区后的挂载点如下：

```shell
sdb      8:16   0  200G  0 disk 
├─sdb1   8:17   0    1G  0 part /efi
├─sdb2   8:18   0   99G  0 part /home
│                               /snapshots
│                               /
├─sdb3   8:19   0  100M  0 part /mnt/efi
└─sdb4   8:20   0 99.9G  0 part /mnt/home
                                /mnt
```

其中sdb1和sdb2是宿主机的挂载点，LFS挂在sdb3和sdb4。

此时，/mnt就是我们的工作目录，在LFS文档中则是/mnt/lfs。总之，在这里设置一下环境变量，以和文档一致并防止误解：

```shell
export LFS=/mnt
```

### 资源

先创建存放资源的位置：`$LFS/sources`。

需要用到的资源列表可以从[wget-list-systemd](https://lfs.xry111.site/zh_CN/12.4-systemd/wget-list-systemd)获取并使用如下方式下载：

```shell
wget --input-file=wget-list-systemd -c --directory-prefix=$LFS/sources
```

添加`-c`标志以启用断点续传和进度条，因为时间可能会很长。