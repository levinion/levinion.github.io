---
title: 网页驱动设备的udev规则设置
created: 2025-02-23 22:37:18
---
## 获取 idVendor

Linux 默认是禁止 USB 访问的，需要创建 udev 规则才能使用网页驱动进行配置。第一步，需要找到设备的 idVendor。

```shell
lsusb
```

如果没有 `lsusb`，安装 `usbutils`：

```shell
sudo pacman -S usbutils
```

根据名称找到对应设备：

```shell
Bus 001 Device 006: ID 1915:ae8c Nordic Semiconductor ASA Ninjutso Sora V2 8K
```

其中 `1915` 即为设备的 idVendor。

你也可以通过该 ID 获取更多设备信息（可选）：

```shell
lsusb -d 1915:ae8c -v
```

## 创建 udev 规则

接着创建 udev 规则：

```shell
sudoedit /etc/udev/rules.d/70-sorav2.rules
```

填入以下内容：

```shell
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1915", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", TAG+="uaccess"
```

## 应用规则

然后重启，或是运行以下命令：

```shell
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## 参考

1. [https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules](https://help.wooting.io/article/147-configuring-device-access-for-wootility-under-linux-udev-rules)
2. [https://wiki.archlinux.org/title/Udev#About_udev_rules](https://wiki.archlinux.org/title/Udev#About_udev_rules)
