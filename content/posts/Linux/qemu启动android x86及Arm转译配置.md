---
title: qemu启动android x86及Arm转译配置
created: 2025-02-10 20:13:24
---
## 前言

之前安装了 Waydroid 和 libhndk，能够正常进行游戏，但会在游戏中途莫名闪退，于是尝试虚拟机方案。对于 x86，Linux 上有 kvm 加速，因此安装 Android x86 并配置转译层。但是，可能是显卡问题（我使用 n 卡），在下载完资源准备进入登录界面时会发生闪退。因此该方案也无效，本文只是记录一下以待后续解决。最终游戏运行方案是使用 genymotion，它也是使用虚拟机，有 qemu 和 VirtualBox 两种后端可选，但游戏能够完美运行，不需要任何额外操作。唯一的缺点大概就是它是个闭源软件，且对于免费用户会在游戏界面中有一个牛皮癣的横幅；`Free for personal use`。

## 安装 qemu

对于 Android X86，我们需要 qemu-system-x86，因此需要安装 qemu 包。而 archlinux 提供了 qemu-base 和 qemu-desktop，这里推荐后者，因为后者还包括了运行虚拟机需要用到的图形界面。

```shell
paru -S qemu-desktop
```

## 安装 Android X86

首先下载 Android X86 的 iso，链接位于：[https://www.android-x86.org/download.html](https://www.android-x86.org/download.html)

创建虚拟磁盘文件：

```shell
qemu-img create -f qcow2 android.qcow2 100G
```

然后编写 qemu 脚本，首先是安装脚本：

```shell
> cat install.sh
qemu-system-x86_64 \
  -enable-kvm \
  -vga std \
  -m 2048 \
  -smp 2 \
  -cpu host \
  -net nic,model=e1000 \
  -net user \
  -cdrom ./android-x86_64-9.0-r2.iso \
  -hda ./android.qcow2 \
  -boot d
```

执行该脚本，可以进入安装界面，逐步操作即可。不知道是不是 Android 不支持 GPT，总之使用 MBR 分区。需要选择自动安装 grub。

安装完毕后，进行必要的设置，不必要的（如谷歌服务）直接跳过即可。

然后重启（直接 ctrl c 即可，或在终端模拟器中执行 `reboot -p`）。以后执行以下脚本即可运行：

```shell
qemu-system-x86_64 \
  -enable-kvm \
  -vga std \
  -m 8192 \
  -smp 8 \
  -machine q35 \
  -cpu host \
  -display gtk \
  -net nic,model=e1000 \
  -net user,hostfwd=tcp::4444-:5555 \
  -hda ./android.qcow2
```

## 配置 ARM 转译

由于 Android 自带一个脚本支持 houndini，这里就不使用另一个库 hndk 了（其实是我没找到如何安装）。

首先我们需要下载 `houndini.sfs`，可以在这里找到所有需要的文件：[https://archive.org/download/androidx86-houdini/](https://archive.org/download/androidx86-houdini/)

对于安卓 9，下载 houndini9 即可，由于向下兼容，因此选择 7 或 8 也可以。

然后将其放入 `/sdcard/arm` 文件夹，如果该文件夹不存在则创建：

```shell
mkdir /sdcard/arm
```

然后在主机上推送文件：

```shell
adb push <path to houndini> /sdcard/arm/
```

然后在虚拟机中执行：

```shell
su root
/system/bin/enable_nativebrige
```

如果遇到文件不存在错误，可尝试运行 `depmod` 命令以创建。

## 调整分辨率

如果需要调整设备分辨率，首先开机进入 Debug 模式，然后执行：

```shell
# https://www.reddit.com/r/Androidx86/comments/1fccm7a/comment/lov6szd/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
mount -o remount,rw /mnt
cd /mnt/grub
vi menu.lst
```

将第一个启动条目的 `quiet` 参数替换为 `nomodeset xforcevesa video=1280x720`，这就是设备的分辨率了。之后重启即可。

```shell
reboot -f
```

待登入系统后，使用 adb 查看分辨率是否更改：

```shell
adb shell wm size
```
