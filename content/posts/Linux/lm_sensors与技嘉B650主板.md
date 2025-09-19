---
title: lm_sensors与技嘉B650主板
created: 2025-03-04 11:29:05
---

`lm_sensors` 能够提供主板上传感器信息，对于查看风扇转速、cpu电压等不常见于各类top中的信息很有帮助。

首先安装 `lm_sensors`，运行，然后一路回车：

```shell
sudo sensors-detect
```

正常来说这就可以了，但是对于技嘉 B650，提示无法找到传感器：

```shell
Sorry, no sensors were detected.
```

仔细观察日志发现：

```shell
Found unknown chip with ID 0x8689
```

也就是说该主板使用了 ITE8689 芯片，并且内核不支持该芯片。

安装 `it87-dkms-git` 包：

```shell
paru -S it87-dkms-git
```

然后加载指定模块：

```shell
sudo modprobe it87 ignore_resource_conflict=1
```

重新运行 `sensors-detect`:

```shell
sudo sensors-detect
```

现在就可以看到主板传感器参数了：

```shell
❯ sensors
...
it8689-isa-0a40
Adapter: ISA adapter
...
```

为了在开机时自动加载该模块，创建以下文件：

```shell
echo "it87" | sudo tee /etc/modules-load.d/it87.conf
```

```shell
echo "options it87 ignore_resource_conflict=1" | sudo tee /etc/modprobe.d/it87.conf
```