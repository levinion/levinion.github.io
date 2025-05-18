---
title: Genymotion无痛指南
created: 2025-02-11 11:13:06
---
继上文，在 Linux 上运行安卓游戏最好的方案大概就是 Genymotion 了。前文也提到过，它对于免费用户，在游戏界面会有一个牛皮癣的横幅；`Free for personal use`。本文就来解决这个。

## Xvfb

Xvfb 能够在 Xorg 中创建一个虚拟的显示屏，适合将一切依赖图形界面运行，而我们却一点不想看见的应用放在那里。

首先我们获取 Xvfb：

```shell
paru -S xorg-server-xvfb
```

```shell
Xvfb :3 -nolisten tcp -screen :3 1280x800x24
```

上条命令在 `DISPLAY=:3` 上创建了一个 `1280x800x24` 的显示器，其中 24 是色深。

有一种更简单的运行方式，即 `xvfb-run <some command>`。如果不附带其他参数，默认会在 `：99` 上创建屏幕并运行传入的命令。

## genymotion-player

然后在创建的虚拟显示器上运行 `genymotion-player`：

```shell
DISPLAY=:3 genymotion-player -n <设备名> -s
```

或是；

```shell
xvfb-run genymotion-player -n <设备名> -s
```

## scrcpy

使用 scrcpy 进行连接：

```shell
scrcpy
```

如果没有，安装：

```shell
paru -S scrcpy
```

## oom

genymotion 的最大问题是它存在内存泄漏，即 `genymotion-player` 占用的内存会越来大，最终导致整个系统运行缓慢。这似乎没有什么好的方法，我所能想到的方案也就是定时杀掉它并重新运行。下面为此所写的一个内存监控脚本：

```python
#!/bin/python3
import subprocess
import os
import time
import sys

def get_pid_by_name(name):
    return int(
        subprocess.check_output(["bash", "-c", f"pidof {name}"]).strip().decode()
    )

def get_memory_by_pid(pid):
    return int(
        subprocess.check_output(
            ["bash", "-c", f"pmap -x {pid} | awk '/total/ {{print $3}}'"]
        )
    )

def run(command):
    with open(os.devnull) as devnull:
        subprocess.Popen(
            command,
            stdout=devnull,
            stderr=devnull,
        )

def main():
    command = " ".join(sys.argv[1:])
    print(command)
    while 1:
        pid = None
        try:
            pid = get_pid_by_name(command)
        except subprocess.CalledProcessError:
            run(["bash", "-c", command])
            time.sleep(5)
            pid = get_pid_by_name(command)
        assert pid is not None
        memory = get_memory_by_pid(pid)
        if memory >= 32 * 1024 * 1024:
            os.kill(pid, 9)
            run(["bash", "-c", command])
        time.sleep(10)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        exit(0)
```

通过 `oom.py xvfb-run genymotion-player -n <device id> -s` 来运行 genymotion，当其内存达到 32G（即我主机内存的一半，你可以进行修改）时，自动重新运行该进程。
