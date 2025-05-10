---
title: 迁移QEMU虚拟机到VMWARE
created: 2025-05-10 21:51:13
---

由于qemu/kvm暂不支持Windows虚拟机的硬件加速，因此使用vmware（对于Windows虚拟机）是一个更好的选择。同时，vmware的GUI做得很不错（毕竟是一个商业软件）。

## 转换磁盘格式

首先转换虚拟磁盘文件格式。`qemu-img`支持从qcow2到vmware使用的vmdk文件格式的转换：

```shell
sudo qemu-img convert -f qcow2 -O vmdk /var/lib/libvirt/images/win10.qcow2 win10.vmdk
```

## 安装虚拟机

这步按照引导完成虚拟机安装即可。其中，如果原先虚拟机未使用UEFI安装，可选择使用BIOS，否则无法引导。

在创建磁盘界面选择已有的磁盘，然后填入vmdk文件的路径。

## 启用内核模块

在启动虚拟机是，可能提示缺少内核模块，按照需求补全即可。

```shell
sudo modprobe vmmon
sudo modprobe vmw_vmci
```

在`/etc/modules-load.d/`中创建一个`vmware.conf`文件以自动加载模块：

```shell
vmmon
vmw_vmci
```

或

```shell
printf "vmmon\nvmw_vmci\n" | sudo tee -a /etc/modules-load.d/vmware.conf
```

## 启用NAT

```shell
sudo systemctl enable --now vmware-networks.service
```

