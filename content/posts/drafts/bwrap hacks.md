## 禁止应用联网

```shell
bwrap \
    --bind / / \
    --dev /dev \
    --unshare-net \
    -- obsidian
```

## 禁止访问某个目录（黑名单）

```shell
bwrap --bind / / --tmpfs $HOME -- ls $HOME
```

## 启动一个最小的bash

```shell
bwrap \
  --bind /usr /usr \
  --bind /lib64 /lib64 \
  -- /usr/bin/bash
```

虽然这能够成功启动，但无法使用ps、top等命令（因为没有挂载/proc，而ps需要使用/proc下的信息才能使用）。

```shell
bwrap \
  --bind /usr /usr \
  --bind /lib64 /lib64 \
  --proc /proc \
  -- /usr/bin/bash
```

这样就能够使用ps，但是它能够访问到所有的主机进程，我们还需要一点隔离。

```shell
bwrap \
  --bind /usr /usr \
  --bind /lib64 /lib64 \
  --proc /proc \
  --unshare-all \
  -- /usr/bin/bash
```

unshare-all为bash进程创建了新的命名空间，

