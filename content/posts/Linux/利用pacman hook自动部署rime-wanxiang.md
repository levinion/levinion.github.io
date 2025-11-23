---
title: 利用pacman hook自动部署rime-wanxiang
created: 2025-11-23 17:13:33
---
最近从自己搓的rime-flypy配置迁移到了rime-wanxiang，能够感受到万象输入法理念的先进性，体验高了不少。更重要的是，wanxiang-pro默认不自动调频，因此也没有维护自己的词库的必要，整体配置文件维护成本又下降了一截。在此之前，由于词库经常发生变化，导致我的dotfiles仓库的git记录极其混乱，这问题终于得到解决了。

但是有个问题，就是rime-wanxiang相关包更新相当频繁，经常需要重新部署。有次在tg中看到群友提出同样的问题，因此决定折腾下，写一个pacman hook进行自动化。

之前部署rime通常是通过portal，或是通过fcitx5的快捷键，但是这在hook是行不通的，总不能在执行hook时模拟个快捷键来部署吧！因此去搜索了一下，看是否可以通过dbus来执行部署操作，然后真找到了：(https://github.com/fcitx/fcitx5-rime/issues/28)。

> ```shell
> qdbus org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1.SetConfig "fcitx://config/addon/rime/deploy" ""
> ```

由于我不用qdbus而使用systemd的busctl，于是改写了下：

```shell
busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 SetConfig sv "fcitx://config/addon/rime/deploy" s ""
```

之后就可以创建一个hook了，在`/usr/share/libalpm/hooks`中创建一个`rime-reload.hook`文件：

```ini
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = rime-wanxiang-* 

[Action]
When = PostTransaction
Exec = /usr/share/libalpm/scripts/rime-reload.hook
```

再在`/usr/share/libalpm/scripts/rime-reload.hook`创建一个hook脚本：

```shell
#!/bin/bash

USER=$(loginctl list-users | tail +2 | head -n1 | cut -d' ' -f 2)

busctl --machine="$USER"@.host --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 SetConfig sv "fcitx://config/addon/rime/deploy" s ""
```

在一个pacman hook中，使用root用户进行执行，因此需要使用`--machine`指定用户，从而找到用户的dbus session。

这里使用`loginctl`来确定当前用户。当然这部分还有改进空间，比如筛选下用户是否活跃，或是对所有用户进行轮询。我就只有一个普通用户，因此不太用得上，上面这个虽然dirty，但它works。其实直接写死也无所谓，但我不太喜欢在脚本中写死用户名。

写好之后对其`chmod`一下。当有包名匹配时，就会重新进行部署，这个时候等待就好啦。