---
title: WSL丢失Wayland以及Xorg套接字
created: 2025-01-19 17:24:42
---
## 前言

WSL 启用 systemd，有时会发生丢失套接字的问题，这导致 wslg 无法正常工作。

这可以通过建立 wslg 中套接字的软链接实现，但由于每次重启都会发生套接字的丢失，因此最好配置一个 oneshot 服务。

## 步骤

1. 首先确保 wslg 正确启用，并且能在 `/mnt/wslg/runtime-dir` 以及 `/mnt/wslg/.X11-unix` 目录下分别找到 `Wayland-0` 和 `X0` 套接字。
2. 然后在指定位置创建如下脚本和服务，并启用：

```shell
# /etc/systemd/user/wslg-patch.sh
ln -fs /mnt/wslg/runtime-dir/* /run/user/1000/
ln -fs /mnt/wslg/.X11-unix/* /tmp/.X11-unix/

> sudo chmod +x wslg-patch.sh
```

```shell
# /etc/systemd/user/wslg-patch.service
[Service]
Type=oneshot
ExecStart=sh -c /etc/systemd/user/wslg-patch.sh

[Install]
WantedBy=default.target

> sudo systemctl --global enable wslg-patch
```

3. 重启 wsl，并且查看 `/run/user/1000` 目录下是否存在 `Wayland-0` 以及 `.X11-unix/X0`。

## 参考

1. [Wayland socket is missing when Systemd enabled](https://github.com/yuk7/ArchWSL/issues/357)
2. [wslg: Can't open display: :0 + X11 server is not running](https://github.com/microsoft/wslg/issues/558)
