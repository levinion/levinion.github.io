## 创建 namespace

```shell
sudo unshare -munip --fork bash
```

创建一个子进程，阻止访问父进程的命名空间。

## chroot

```shell
exec chroot /path/to/container
```

## 网络

使子进程只能访问自己的进程

```shell
mount -t proc none /proc
```
