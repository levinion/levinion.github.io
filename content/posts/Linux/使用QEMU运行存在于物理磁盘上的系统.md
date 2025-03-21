---
title: 使用QEMU运行存在于物理磁盘上的系统
created: 2025-02-15 00:05:49
---


## 前言

当前运行多系统的方案大概有以下几种：一是传统的虚拟机方案，这种方案的优势在于能够同时运行多个系统，缺点是性能损失比较严重，特别是在host系统性能不高的情况下；另一种方案是双系统或多系统，虽然能够带来原生的性能，但是磁盘浪费严重，且无法同时运行，需要重启以进行切换。如果虚拟机能够挂载存在于真实物理磁盘上的系统，前两者的劣势也就迎刃而解。因为它既保留着双/多系统的前提，能够在需要的时候切换到特定系统从而保留原生系统的性能优势，而且还能够主系统临时唤起另一系统进行操作。并且，这种方案是能够做到的。

## 安装QEMU

我们通过QEMU来实现物理磁盘挂载。QEMU是一个虚拟机工具，能够实现对各种硬件和架构的模拟，并且在Linux下面能够通过kvm加速获得相当好的性能。在ArchLinux中，我们可以非常简单地安装QEMU：

```shell
paru -S qemu
```

对于我们的需求，只需要x86平台，因此选择`qemu-desktop`包。它相比`qemu-base`多了GUI相关的组件。

## 命令

对于不喜欢编写命令的人来说，可以尝试使用图形界面的`virt-manager`，但是说实话，它的界面做得相当糟糕，而且我也不喜欢xml的配置语法，因此还是选择使用`qemu`的cli工具来编写启动脚本。

```shell
sudo qemu-system-x86_64 -enable-kvm \
    -machine q35 \
    -drive if=pflash,format=raw,file=/usr/share/edk2/x64/OVMF_CODE.4m.fd \
    -cpu host \
    -smp 8 \
    -m 32G \
    -nic user \
    -vga std \
    -display sdl,gl=on \
    -drive file=/dev/disk/by-id/nvme-SHPP41-2000GM_ADCBN54441070BS48,format=raw,media=disk,cache=none \
```

上面大概就是能够启动系统的最简脚本了。

其中，`-enable-kvm`参数表明开启kvm，这个参数与`-accel kvm`等同。

`-machine q35`定义了一个q35类型的机器。q35是一个相比i440fx更为现代的芯片组，一般搭配ovmf一起使用。ovmf同样，它相比默认的seabios更新，提供了更多功能，如安全启动以及更快的启动时间等等。ovmf需要安装，在ArchLinux上，需要安装`edk2-ovmf`包。

`-cpu host`选择使用与主机cpu功能相同的cpu，这是最简单也最通用的写法。一般不使用`-cpu max`，这启用了全部的kvm功能，可能会导致无法启动。`-smp`指定cpu的物理核数，如果不设置则虚拟机只能识别一个核，因而会非常卡。

`-m`很简单，分配给虚拟机的内存，值得注意的是，如果不指定，则默认分配128MB；且如果不写单位，默认单位会是MB。因此指定该参数且写上单位会是个好习惯。

`-nic user`表示使用用户态网络，也就是NAT，如果不想麻烦，这就是最省心的网络连接方式。

`-vga std`是通用的显示配置方案。

`-display sdl,gl=on`表示使用sdl作为图形界面后端，同时启用OpenGL。与此同时还有gtk后端可以选。

`-drive file=...,format=raw,media=disk,cache=none`就是挂载物理磁盘了。其中，file参数指定磁盘位置，在`/dev/disk/by-id/`目录下找到对应磁盘的uuid。由于挂载的是物理区块，所以建议关闭cache。

## 其他

### 左上角存在黑窗

如果左上角出现`parallelxx console`，添加以下两条：

```shell
... \
-serial none \
-parallel none \
... \
```

### 启用virtio

一般来说，启用virtio可以提供更好的性能。

`-drive file=...,format=raw,media=disk,if=virtio,cache=none`中添加virtio选项

`-nic user,model=virtio-net-pci`，添加model类型

`-device virtio-vga-gl`和`-vga none`，但是只支持Linux虚拟机

另外，用户机需要安装virtio驱动，对于windows来说，安装`virtio-win`。如果不想切换系统，可以使用`virtio-win`包，并且挂载cdrom：

```shell
-cdrom /var/lib/libvirt/images/virtio-win.iso
```

然后进入虚拟机安装即可。

### 对于Windows

对于Windows虚拟机，可以修改cpu选项为：`-cpu host,hv-relaxed,hv-vapic,hv-spinlocks=0x1fff,hv-time`，这似乎能提供类似于hyper-v的优化效果（玄学）。

## 参考

1. <https://wiki.archlinux.org/title/QEMU>
2. <https://www.qemu.org/docs/master/system/index.html>