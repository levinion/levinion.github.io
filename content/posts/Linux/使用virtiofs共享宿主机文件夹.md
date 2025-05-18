---
title: 使用virtiofs共享宿主机文件夹
created: 2025-04-12 21:08:21
---
## 前言

将宿主机文件夹共享给虚拟机一般有两种途径：

- 通过网络共享，如 samba、webdav
- 共享内存，如 virtiofs

如果使用 `libvirt` 管理虚拟机，`virtiofs` 就是一个很好的方式。它使用共享内存的方式，因此无需经过网络 I/O，延迟可控

## 宿主机

宿主机需要在 `virt-manager` 中添加 `FileSystem` 设备，其中：

- Driver：选择 `virtiofs`
- Source Path：即要传入的文件夹路径，手动填写即可
- Target Path：即目标路径。需填写子卷名（一般作为 Z 盘挂载），因此无需绝对路径。

## 虚拟机

这里特指 Windows 虚拟机。为了使虚拟机支持 `virtiofs`，需要安装以下两个驱动：

- [VirtIO-Win](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers)
- [WinFsp](https://winfsp.dev/)

安装完毕后，在开始菜单搜索 `服务`。或 `Win+R`，输入：

```bat
Services.msc
```

找到 `VirtIO-FS Service`，右键选择启动（因为以 V 开头，所以从下往上翻比较快）。

为了开机自动启动服务，右键修改属性，将启动类型设为自动。

现在打开文件管理器，即可看到挂载成功的目录。
