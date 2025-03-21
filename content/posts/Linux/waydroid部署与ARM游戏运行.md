---
title: waydroid部署与ARM游戏运行
created: 2025-02-09 20:19:52
---
在Linux系统上运行安卓游戏是有困难的，因为大多数安卓模拟器都只支持Windows。目前比较好的方案大概只有Waydroid了。Waydroid是Anbox项目的后继者，提供了在X86架构下运行安卓的方案。至于Arm，就需要依靠Arm转译库了。

## 准备Wayland

Waydroid只能在Wayland下运行，因此需要一个Wayland环境。如果已经在使用Wayland可以跳过这步。对于那些X11用户，可以安装Weston，它提供了一种在X11上运行Wayland容器的方法。

```shell
paru -S weston
```

## 特定模块的内核

你需要具有特定模块（binder）的内核来运行waydroid，最简单的方式是使用`linux-zen`内核。当然如果你使用其他不包含该模块的内核，可以使用dkms来添加该模块：

```shell
paru -S binder_linux-dkms
```

## 部署Waydroid

首先安装waydroid；

```shell
paru -S waydroid
```

然后初始化；

```shell
waydroid init
```

启用waydroid容器：

```shell
sudo systemctl enable waydroid-container --now
```

打开weston，并在其中运行：

```shell
waydroid session start
```

以及

```shell
waydroid show-full-ui
```

如果一切正常，你应该能看到ui界面。

## 安装额外组件

为求方便，安装：

```shell
paru -S waydroid-script-git
```

这个包提供了一些方便的脚本来管理waydroid组件。

运行以下命令，并选择安装gapps和libndk/libhoudini（注意选择Android11）。一般来说，amd cpu选择libndk，intel cpu选择libhoudini会具有更好的性能。

```shell
sudo waydroid-extras
```

重启waydroid-container服务：

```shell
sudo systemctl restart waydroid-container
```

## 注册设备

我们需要注册设备以保证谷歌服务能够正常使用：

```shell
sudo waydroid-extras
```

选择`Get Google Device ID to Get Certified`，并根据提示操作以注册设备id。之后等待十分钟左右以等待注册完毕。

## 问题排查

### 日志

如果发现问题，首先查看日志：

```shell
cat /var/lib/waydroid/waydroid.log
```

### 未找到pulse

```
No such file or directory - Failed to mount "/run/user/1000/pulse/native" onto "/usr/lib/lxc/rootfs/run/xdg/pulse/native"
```

waydroid依赖libpulse，如果你使用pipewire，需要安装；

```shell
paru -S pipewire-pulse
```

### Nvidia

由于waydroid不支持N卡的硬件加速，因此需要使用软件渲染。

```shell
sudoedit /var/lib/waydroid/waydroid_base.prop
```

然后修改以下两项：

```shell
ro.hardware.gralloc=default
ro.hardware.egl=swiftshader
```

重启waydroid-container服务：

```shell
sudo systemctl restart waydroid-container
```

该文件在执行`sudo waydroid-extras`后会被覆盖，因此如果出现无法显示ui界面的情况，请第一时间确认该文件配置是否正确。

修改后如果不起作用，尝试重启。

## 启动游戏

### 安装adb

我们需要adb来与设备交互，如果你没有安装过adb，执行：

```
paru -S android-tools
```

然后重启。

### 获取设备

如果adb能够正常获取到设备信息，表示waydroid已正常运行：

```shell
> adb devices
List of devices attached
192.168.240.112:5555	device
```

### 安装游戏

```shell
adb install xxx.apk
```

然后可以在系统中看到游戏已成功安装，如果ARM翻译库正常作用，这时游戏应当就能运行了。

## 其他设置

### waydroid

使用以下命令以设置设备分辨率（前提是保证waydroid的分辨率小于窗口分辨率）

```shell
waydroid prop set persist.waydroid.width <number>
waydroid prop set persist.waydroid.height <number>
```

使用以下命令取消waydroid的睡眠：

```shell
waydroid prop set persist.waydroid.suspend off
```

### weston

针对使用weston的用户，可以按照需求修改配置文件：

```shell
[core]
xwayland=false
idle-time=0

[keyboard]
keymap_layout=gb

[output]
name=screen0
mode=1024x600

[launcher]
icon=/usr/share/icons/AdwaitaLegacy/24x24/legacy/utilities-terminal.png
path=/usr/bin/weston-terminal

[autolaunch]
path=<脚本的绝对路径>
watch=false
```

比较重要的是`idle-time`，将其设置为0以阻止weston的自动锁定。可以使用autolaunch功能自动执行启动脚本。以下脚本开启weston时自动打开安卓应用程序：

```shell
#!/bin/bash
waydroid session stop
waydroid session start &
waydroid show-full-ui &
sleep 15
waydroid app launch com.bilibili.azurlane
```

weston有个比较坑的点是它不支持相对路径，在配置文件中必须使用绝对路径，甚至不支持`～`扩展和`$HOME`环境变量。

另外，weston默认不读任何位置的配置文件，需要使用`-c`来指定配置文件路径，这里它支持`～`和`$HOME`了，但是仍然不支持相对路径（汗），注意即可。