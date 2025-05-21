---
title: understanding initramfs
created: 2025-05-21 18:22:48
---
## ramfs

要理解 initramfs，首先需要理解 ramfs。

ramfs 是一个非常简单的、基于内存的文件系统。tempfs 是 ramfs 的衍生版本。

也就是说，当加载内核后，内核将 initramfs 中的文件解压进内存，然后进行早期用户空间的初始化工作。

## 作用

initramfs 用作早期用户空间根文件系统，负责内核加载后、执行 init 之前的一些准备工作。在有 grub（或其他引导加载器）的系统中，它由 grub 调用。

早期用户空间初始化流程如下：

- 加载必要的内核模块：磁盘控制器、文件系统驱动、网络驱动
- 挂载真实根文件系统
- 执行 init

当执行 init 后，进入后期用户空间，initramfs 也就没用了。

另外，如果磁盘经过加密，需要在 initramfs 阶段进行解密，之后再挂载经解密后的磁盘。

## 文件树

可以在/boot/下找到 initramfs-linux.img 文件。用 file 查看一下格式，发现是一个 cpio 格式的归档文件。

> initramfs-linux.image 也可能经过压缩，这取决于生成 initramfs 的软件的配置。在 archlinux 中则是/etc/mkinitcpio.conf

```shell
❯ file initramfs-linux.img
initramfs-linux.img: ASCII cpio archive (SVR4 with no CRC)
```

然后使用 `lsinitcpio` 命令提取：

```shell
❯ mkdir fakefs && cd fakefs
❯ lsinitcpio -x ../initramfs-linux.img
```

提取 initramfs-linux.img 后得到：

```shell
.
├── bin -> usr/bin
├── buildconfig
├── config
├── dev
├── early_cpio
├── etc
│   ├── fstab
│   ├── initrd-release -> ../usr/lib/os-release
│   ├── ld.so.cache
│   ├── ld.so.conf
│   ├── modprobe.d
│   │   ├── blacklist.conf
│   │   └── vmware-fuse.conf
│   ├── mtab -> ../proc/self/mounts
│   └── os-release -> ../usr/lib/os-release
├── hooks
│   ├── keymap
│   └── udev
├── init
├── init_functions
├── keymap.bin
├── keymap.utf8
├── lib -> usr/lib
├── lib64 -> usr/lib
├── new_root
├── proc
├── run
├── sbin -> usr/bin
├── sys
├── tmp
├── usr
│   ├── bin
│   │   ├── [ -> busybox
│   │   ├── arch -> busybox
│   │   ├── ascii -> busybox
│   │   ├── ash -> busybox
│   │   ├── awk -> busybox
│   │   ├── base32 -> busybox
│   │   ├── base64 -> busybox
│   │   ├── basename -> busybox
│   │   ├── bc -> busybox
│   │   ├── blkdiscard -> busybox
│   │   ├── blkid
│   │   ├── busybox
│   │   ├── bzip2 -> busybox
│   │   ├── cat -> busybox
│   │   ├── chgrp -> busybox
│   │   ├── chmod -> busybox
│   │   ├── chown -> busybox
│   │   ├── 
...
│   │   └── yes -> busybox
│   ├── lib
│   │   ├── ld-linux-x86-64.so.2
│   │   ├── libacl.so.1 -> libacl.so.1.1.2302
│   │   ├── libacl.so.1.1.2302
│   │   ├── libaudit.so.1 -> libaudit.so.1.0.0
│   │   ├── libaudit.so.1.0.0
│   │   ├── libblkid.so.1 -> libblkid.so.1.1.0
│   │   ├── libblkid.so.1.1.0
│   │   ├── libc.so.6
│   │   ├── libcap-ng.so.0 -> libcap-ng.so.0.0.0
│   │   ├── libcap-ng.so.0.0.0
│   │   ├── libcap.so.2 -> libcap.so.2.76
│   │   ├── libcap.so.2.76
│   │   ├── libcrypt.so.2 -> libcrypt.so.2.0.0
│   │   ├── libcrypt.so.2.0.0
│   │   ├── libcrypto.so.3
│   │   ├── libgcc_s.so.1
│   │   ├── libkmod.so.2 -> libkmod.so.2.5.1
│   │   ├── libkmod.so.2.5.1
│   │   ├── liblzma.so.5 -> liblzma.so.5.8.1
│   │   ├── liblzma.so.5.8.1
│   │   ├── libm.so.6
│   │   ├── libmount.so.1 -> libmount.so.1.1.0
│   │   ├── libmount.so.1.1.0
│   │   ├── libpam.so.0 -> libpam.so.0.85.1
│   │   ├── libpam.so.0.85.1
│   │   ├── libseccomp.so.2 -> libseccomp.so.2.5.6
│   │   ├── libseccomp.so.2.5.6
│   │   ├── libz.so.1 -> libz.so.1.3.1
│   │   ├── libz.so.1.3.1
│   │   ├── libzstd.so.1 -> libzstd.so.1.5.7
│   │   ├── libzstd.so.1.5.7
│   │   ├── modprobe.d
│   │   │   ├── 99-opentabletdriver.conf
│   │   │   ├── nvdimm-security.conf
│   │   │   ├── nvidia-sleep.conf
│   │   │   ├── nvidia-utils.conf
│   │   │   └── systemd.conf
│   │   ├── modules
│   │   │   └── 6.14.6-arch1-1
│   │   │       ├── kernel
│   │   │       │   └── drivers
│   │   │       │       ├── hid
│   │   │       │       │   ├── hid-generic.ko.zst
│   │   │       │       │   └── usbhid
│   │   │       │       │       └── usbhid.ko.zst
│   │   │       │       ├── misc
│   │   │       │       │   └── rpmb-core.ko.zst
│   │   │       │       ├── mmc
│   │   │       │       │   └── core
│   │   │       │       │       ├── mmc_block.ko.zst
│   │   │       │       │       └── mmc_core.ko.zst
│   │   │       │       ├── nvme
│   │   │       │       │   ├── common
│   │   │       │       │   │   └── nvme-auth.ko.zst
│   │   │       │       │   └── host
│   │   │       │       │       ├── nvme-core.ko.zst
│   │   │       │       │       └── nvme.ko.zst
│   │   │       │       ├── scsi
│   │   │       │       │   └── virtio_scsi.ko.zst
│   │   │       │       └── usb
│   │   │       │           └── storage
│   │   │       │               ├── uas.ko.zst
│   │   │       │               └── usb-storage.ko.zst
│   │   │       ├── modules.alias.bin
│   │   │       ├── modules.builtin.alias.bin
│   │   │       ├── modules.builtin.bin
│   │   │       ├── modules.dep.bin
│   │   │       ├── modules.devname
│   │   │       ├── modules.softdep
│   │   │       └── modules.symbols.bin
│   │   ├── os-release
│   │   ├── systemd
│   │   │   ├── libsystemd-shared-257.5-3.so
│   │   │   └── systemd-udevd -> /usr/bin/udevadm
│   │   └── udev
│   │       ├── ata_id
│   │       ├── rules.d
│   │       │   ├── 50-udev-default.rules
│   │       │   ├── 60-persistent-storage.rules
│   │       │   ├── 64-btrfs.rules
│   │       │   └── 80-drivers.rules
│   │       └── scsi_id
│   ├── lib64 -> lib
│   ├── local
│   │   ├── bin
│   │   ├── lib
│   │   └── sbin
│   └── sbin -> bin
├── var
│   └── run -> ../run
└── VERSION
```

- 可以看到，在 `usr` 中，包括了许多 `busybox` 命令以及依赖的动态库。
- 在 `etc` 下，可以看到 `fstab`，但此处 `fstab` 为空，因为真实文件系统会由 init 脚本进行挂载。`modprobe.d` 中有一些用户配置，在此处设置黑名单，以防黑名单模块在早期用户空间就被载入。
- 在 `usr/lib/modprobe.d` 中，可以看到早期用户空间加载的模块，主要包括 systemd 和显卡。
- 在 `usr/lib/modules` 中，可以看到有关磁盘设备的驱动。

在 `initramfs` 中执行具体操作被称为 hook，这可以在 `/etc/mkinitcpio.conf` 中找到：

```shell
HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)
```

大致就是加载 initramfs，识别和挂载设备（包括键盘等），加载微码、模块、终端字体、存储设备，加载文件系统驱动，运行文件系统检查工具等。具体做了什么可以查看：[Common_hooks](https://wiki.archlinux.org/title/Mkinitcpio#Common_hooks)

在所有流程执行完毕后，initramfs 的准备工作也就完成了，init 就从此处开始执行。

## init

在 `sbin` 下面可以找到 `init` 文件，这就是接下来要调用的脚本。可以看到它由 `busybox` 提供。

具体使用哪种工具作为 init 是由 `/etc/mkinitcpio.conf` 中定义的 hook 决定的（`base` 使用 `busybox`，`systemd` 使用 `systemd` 作为 init），默认情况下应该使用的是 `busybox`。

```shell
❯ file init
init: symbolic link to busybox
```

一旦 init 完成根文件系统挂载，将剩余工作交由 `systemd` 继续。这个操作由类似以下的命令执行：

```shell
switch_root /new_root /usr/lib/systemd/systemd
```

具体代码可以查看 [busybox](https://github.com/brgl/busybox/blob/abbf17abccbf832365d9acf1c280369ba7d5f8b2/util-linux/switch_root.c#L93-L153)，核心逻辑是一个 exec 系统调用：

```shell
// Exec real init
execv(argv[0], argv);
```

因此，进入系统后的第一个进程即为`systemd`：

```shell
~ ❯ ps -p 1
    PID TTY          TIME CMD
      1 ?        00:00:01 systemd
```

