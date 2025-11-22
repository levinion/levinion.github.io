---
title: Linux之安卓模拟器总集篇
created: 2025-02-12 19:36:51
---
Linux 下安卓模拟器并不如 Windows 下方便选择，多数都有其痛点，经过几天的折腾终于有了稳定的方案，下面就来讲下折腾的经过。

## waydroid

waydroid 是第一个选择的方案。在英文社区中，说到 Linux 下的安卓模拟器，waydroid 基本都会被推荐。说是模拟器，其实是一个容器，因此相较传统模拟器具有比较好的性能。但是其缺点在于，它只能在 Wayland 下运行；这点虽说对于 Wayland 用户来说很难算是个缺点，但是对我这种还在 X11 的用户，就只能跑在 Weston 中。而在实际运行过程中，游戏会经常发生闪退，并且没有任何报错日志，因此最终放弃。这点不知是不是 weston 引起的，由于我不使用 Wayland，也就无从验证。

另外，由于 waydroid 对 N 卡支持不好，因此只能使用软件渲染，从而导致很大的 CPU 占用（对 9950X 整体 30% 的占用）。

对于详细的安装过程，可以查看我前面的文章：[waydroid 部署与 ARM 游戏运行](https://blog.maruka.top/posts/Linux/waydroid%E9%83%A8%E7%BD%B2%E4%B8%8EARM%E6%B8%B8%E6%88%8F%E8%BF%90%E8%A1%8C/)

## Qemu + Android X86

由于容器方案行不通（只是我以为），这次就换用模拟器。由于 Qemu 直接模拟 ARM 架构的安卓会无法使用 kvm 加速从而导致较大的性能损失，于是继续采用 Android X86 + 转译库的方案。最终的结果见前文：[qemu 启动 android x86 及 Arm 转译配置](https://blog.maruka.top/posts/Linux/qemu%E5%90%AF%E5%8A%A8android%20x86%E5%8F%8AArm%E8%BD%AC%E8%AF%91%E9%85%8D%E7%BD%AE/)

经过配置转译库，游戏能够成功进入和下载资源，但总是在登录界面发生闪退，即使更换 BlissOS 镜像仍有同样情况，因此放弃。

通过 Qemu，可以对虚拟机进行 kvm 加速，虽然似乎无法使用 virtio-gpu，但能启用 OpenGL，因此运行效率似乎还行，但既然无法工作，那性能也就无从说起。

## genymotion

genymotion 也是一个很老牌的安卓模拟器解决方案了，在 Linux 上它有两个后端：qemu 和 VirtualBox。值得一提的是，它也是采用了虚拟机 + Android X86 + Arm 转译方案。但是与之前自行配置的安卓 X86 虚拟机不同，它运行得很好。详细部署方案可以查看我上一篇文章：[Genymotion 无痛指南](https://blog.maruka.top/posts/Linux/Genymotion%E6%97%A0%E7%97%9B%E6%8C%87%E5%8D%97/)。

当我刚开始发现游戏能够正常运行时，一切都感觉很好；但事实证明，Genymotion 并非无痛：安卓模拟器本身运行得很好，但是它自带的 genymotion-player 会导致严重的内存泄漏，导致不到一个小时就会吃满我的 64G 内存（在这之前似乎从来没有不够用过！）。如果我想要脱离 genymotion-player，使用它调用的原始命令启动虚拟机，它会停在 bios 页面且完全无法 boot，大概是 genymotion-player 除了调用 qemu 之外还做了其他工作。由于它不开源所以也无从深挖，这个方案最终也是放弃了。

## redroid

在浏览无头 waydroid 话题时，偶尔发现有人提到了 redroid，这就是今天的主角了。

redroid 是一个基于 docker 的安卓容器，没有 UI 界面，但提供了 adb 连接；其中内置了 libnhk，从而能够开箱即用地支持 ARM 应用程序。虽说是docker容器，实际内部打包了一个qemu虚拟机。但由于它做了一些工作，能够自动选择显卡，因此在多显卡环境中能够比较正常地运行。当nvidia独显和amd核显均启用时，会自动选择在核显上运行，因此体验尚可。只有n卡的用户不保证能用。

redroid 的配置很简单，直接修改 docker 运行命令即可。

```shell
  docker run -itd --rm --privileged \
    -v ~/docker/redroid/data:/data \
    -p 5555:5555 \
    --name redroid13 \
    redroid/redroid:13.0.0-latest \
    androidboot.redroid_width=1280 \
    androidboot.redroid_height=720 \
    androidboot.redroid_fps=60 \
    androidboot.redroid_gpu_mode=host
```

然后使用 adb 连接到本地的 5555 端口：

```shell
adb connect localhost:5555
```

然后按照以前的方式使用 adb 安装应用：

```shell
adb install xxx.apk
```

容器中所有的数据均能够被同步到本地目录进行持久化 `~/docker/redroid/data`，因此只需要安装一遍就行，即使更换镜像也不用重新安装。

对于没用过 docker 的人，按照以下步骤安装 docker，然后运行上述命令即可：

```shell
paru -S docker
sudo systemctl enable docker --now
sudo usermod -a -G docker <username>
```

### podman

对于 `podman` 用户，目前无法使用 `rootless` 模式来运行 redroid，如果试图这样做，容器会立即退出且没有任何错误消息。

因此需要使用以下方式来运行 `podman`（即使用 `sudo pacman` 替换上面的 `docker`）：

```shelll
  sudo podman run -itd --rm --privileged \
    -v ~/docker/redroid/data:/data \
    -p 5555:5555 \
    --name redroid13 \
    redroid/redroid:13.0.0-latest \
    androidboot.redroid_width=1280 \
    androidboot.redroid_height=720 \
    androidboot.redroid_fps=60 \
    androidboot.redroid_gpu_mode=host
```

如果提示未找到镜像，将以下内容加入到 `/etc/containers/registries.conf`（对于 `rootless` 则是 `~/.config/containers/registries.conf`）

```toml
[registries.search]
registries = ['docker.io']
```

现在应该能够正常运行，使用 `sudo podman ps` 查看当前容器运行状态。

如果本地未安装 docker，可以使用 `alias docker "sudo podman"` 的方式来以 `rootfull` 方式运行 `podman`（就像以前运行 docker 一样）。

另外，如果不想总是输入密码来允许提权（虽然是个好习惯）：

```shell
sudo visudo

# 然后在文件末新增：

%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/podman
```

### DNS

当不指定DNS服务器时，默认使用的是google的`8.8.8.8`, 对一些国内应用来说并不合适。因此可以添加以下选项自定义DNS：

```shell
# ...
androidboot.redroid_net_ndns=1 \
androidboot.redroid_net_dns1=223.5.5.5
```
