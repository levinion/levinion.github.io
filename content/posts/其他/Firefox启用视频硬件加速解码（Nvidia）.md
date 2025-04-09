---
title: Firefox启用视频硬件加速解码（Nvidia）
created: 2025-04-09 14:24:43
---

## 1. 安装驱动

安装`libva-nvidia-driver`：

```shell
sudo pacman -S libva-nvidia-driver
```

查看vaapi支持（可选）：

```shell
sudo pacman -S libva-utils
vainfo
```

## 2. 修改内核参数

编辑grub配置。

编辑`/etc/default/grub`，在`GRUB_CMDLINE_LINUX_DEFAULT`中新增：

```
nvidia-drm.modeset=1
```

更新grub配置：

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 3. firefox配置

- 修改`media.ffmpeg.vaapi.enabled`为`true`
- 修改`media.rdd-ffmpeg.enabled`为`true`
- 修改`gfx.x11-egl.force-enabled`为`true`
- 修改`widget.dmabuf.force-enabled`为`true`

## 4. 环境变量

```shell
set -gx MOZ_DISABLE_RDD_SANDBOX 1
set -gx LIBVA_DRIVER_NAME nvidia
set -gx __EGL_VENDOR_LIBRARY_FILENAMES /usr/share/glvnd/egl_vendor.d/10_nvidia.json
```

## 5. 检查

完成以上步骤后重启。在火狐中打开`about:support`，查看当前硬件解码支持。