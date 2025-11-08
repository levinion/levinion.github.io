通过配合使用unshare和mount -t overlay可以创建一个overlayfs：

```shell
unshare -rm bash -c "
mount -t overlay overlay -o lowerdir=$LOWERDIR,upperdir=$UPPERDIR,workdir=$WORKDIR $LOWERDIR
$CMD
"
```

可以使用bwrap轻松创建一个Overlayfs

```shell
bwrap --bind / / --overlay-src $LOWERDIR --overlay $UPPERDIR $WORKDIR $LOWERDIR -- $CMD
```
