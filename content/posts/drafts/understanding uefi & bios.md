BIOS: Basic Input Output System

BIOS是固件（firmware）上的一小段代码。

它会先检查硬件是否正常，然后加载（操作系统）磁盘，将控制权交给操作系统

## BIOS的缺陷

BIOS依赖MBR（Master boot record）加载磁盘，最多只能容纳2TB以下的磁盘。另外，它只支持很原始的图形操作（古老的蓝色界面）。

因此，UEFI（Unified extensible firmware interface）应运而生。它比BIOS（MBR）支持的容量更大（通过GPT）、也更快，以及图形界面和鼠标支持。

## 如何分辨BIOS和UEFI

```shell
ls /sys/firmware/efi
```

```shell
efibootmgr
```