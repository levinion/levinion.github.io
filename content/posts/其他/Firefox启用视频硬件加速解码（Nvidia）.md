---
title: Firefox启用视频硬件加速解码（Nvidia）
created: 2025-04-09 14:24:43
---
## 1. 安装驱动

安装 `libva-nvidia-driver`：

```shell
sudo pacman -S libva-nvidia-driver
```

查看 vaapi 支持（可选）：

```shell
sudo pacman -S libva-utils
vainfo
```

## 2. 修改内核参数

由于ArchLinux打包已默认启用该参数，因此可以跳过。

这可以通过以下方式确认：

```shell
> sudo cat /sys/module/nvidia_drm/parameters/modeset
Y
```

如果没有，继续执行此节步骤：

编辑 grub 配置。

编辑 `/etc/default/grub`，在 `GRUB_CMDLINE_LINUX_DEFAULT` 中新增：

```
nvidia-drm.modeset=1
```

更新 grub 配置：

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 3. Firefox 配置

- 修改 `media.ffmpeg.vaapi.enabled` 为 `true`
- 修改 `media.rdd-ffmpeg.enabled` 为 `true`
- 修改 `gfx.x11-egl.force-enabled` 为 `true`
- 修改 `widget.dmabuf.force-enabled` 为 `true`

## 4. 环境变量

```shell
export MOZ_DISABLE_RDD_SANDBOX=1
export LIBVA_DRIVER_NAME=nvidia
export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json
```

## 5. 检查

完成以上步骤后重启。在火狐中打开 `about:support`，查看当前硬件解码支持。
