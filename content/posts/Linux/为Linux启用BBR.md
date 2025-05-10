---
title: 为Linux启用BBR
created: 2025-05-06 23:56:04
---

## BBR

[BBR](https://github.com/google/bbr)是谷歌开发的一种TCP拥塞算法，相比传统的Cubic能更加有效地利用网络资源，从而减少延迟和增加吞吐量。目前有三个版本，Linux最新内核使用v3。

## 如何启用

默认情况下，TCP拥塞算法一般为Cubic，这可以通过以下方式查看：

```shell
> sysctl net.ipv4.tcp_congestion_control
net.ipv4.tcp_congestion_control = cubic
```

要开启bbr，先加载`tcp_bbr`模块：

```shell
sudo modprobe tcp_bbr
```

要自动加载模块，在`/etc/modules-load.d`中新建一个文件：

```shell
echo "tcp_bbr" | sudo tee /etc/modules-load.d/bbr.conf
```

使用以下命令检查bbr是否可用：

```shell
> sysctl net.ipv4.tcp_available_congestion_control
net.ipv4.tcp_available_congestion_control = reno cubic bbr
```

然后修改内核参数。在`/etc/sysctl.d/99-sysctl.conf`中添加如下配置：

> 有些地方可能会将配置写在/etc/sysctl.conf，这对于大多数发行版来说没有问题，但对于archlinux来说无效，因为archlinux已于2013年弃用了这个配置文件

```shell
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = cake
```

执行`sudo sysctl -p`以应用。这应该输出：

> 对于archlinux用户来说应该是`sudo sysctl -p /etc/sysctl.d/99-sysctl.conf`

```shell
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = cake
```

如果提示找不到`net.core.default_qdisc`，尝试重启。

对于队列使用cake还是fq好有一些争议，但在日常使用场景下，应该不会有太大差别，因此可以随意选择一个你喜欢的。

## 参考

1. [huge-improve-network-performance-by-change-tcp-congestion-control-to-bbr](https://djangocas.dev/blog/huge-improve-network-performance-by-change-tcp-congestion-control-to-bbr/)
2. [Sysctl-ArchWiki](https://wiki.archlinux.org/title/Sysctl)