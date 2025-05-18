---
title: archlinux速查速记
created: 2025-02-13 17:32:50
---
## 安装

对于安装过程，建议参考：[archlinux 简明指南](https://arch.icekylin.online/)以及 [archwiki](https://wiki.archlinux.org/title/Installation_guide)。

对于那些想要快速安装的用户，推荐使用我写的脚本：[iarch-install](https://github.com/levinion/iarch-install)。具体的安装过程详见 README。

本文主要讲解一下进系统后要做的一些设置。

## 一些习惯

对于一些常用的软件，都应当维护一份配置文件。对于我来说，喜欢需要维护的配置文件放在一个文件夹中，比如 dotfiles，然后将其软链接到具体的路径，比如 `~/.config/xxx`，这样就能方便地使用 Git 进行配置文件的管理和同步。如：

```shell
ln -s ~/<path to dotfiles>/dotfiles/xxx ~/.config/xxx
```

对于环境变量，我喜欢全部放在 shell 的配置文件中。一方面，前面已经有了 `/etc/environment` 被弃用的案例，另一方面也应该为单一用户，而非所有用户，维护一份单独的配置文件，即使这台电脑只有一个人使用。所以你能看见我在后文中将环境变量全部写进 shell 配置文件（我使用 fish，因此你或许会感到语法有些奇怪 lol）。

当然这两点也是仅供参考。下面开始正文。

## 中文输入法

安装 fcitx5、rime：

```shell
paru -S fcitx5-im fcitx5-rime
```

设置环境变量

```shell
set -gx QT_IM_MODULE fcitx5
set -gx GTK_IM_MODULE fcitx5
set -gx XMODIFIERS "@im=fcitx5"
set -gx XIM fcitx5
set -gx XIM_PROGRAM fcitx5
set -gx SDL_IM_MODULE fcitx5
set -gx INPUT_METHOD fcitx5
set -gx GLFW_IM_MODULE ibus
```

修改 fcitx5 配置：

```shell
fcitx5-configtool
```

修改 rime 配置，默认配置文件夹路径为：

```
~/.local/share/fcitx5/rime/
```

## 显卡驱动

首先查询显卡型号：

```shell
lspci -k -d ::03xx
```

对于 40 系之后较新的显卡，建议安装 `nvidia-open-beta-dkms`：

```shell
paru -S nvidia-open-beta-dkms nvidia-utils-beta lib32-nvidia-utils-beta nvidia-settings
```

修改 `/etc/mkinitcpio.conf`，删除 HOOKS 数组中的 `kms`，结果如下：

```shell
HOOKS=(base udev autodetect microcode modconf keyboard keymap consolefont block filesystems fsck)
```

重新生成 initramfs

```shell
mkinitcpio -P
```

## HIDPI

对于 GDK 和 QT 程序，设置如下环境变量：

```shell
set -gx GDK_DPI_SCALE -1
set -gx GDK_SCALE 2
set -gx XCURSOR_SIZE 32
set -gx QT_AUTO_SCREEN_SCALE_FACTOR 2
set -gx QT_ENABLE_HIGHDPI_SCALING 0
set -gx QT_SCALE_FACTOR 2
```

对于火狐，进入 about:config 界面，修改 `layout.css.devPixelsPerPx` 属性，调整到满意为止。

对于 electron；

```shell
echo "--force-device-scale-factor=2" > ~/.config/electron-flags.conf
```

但是一些 electron 应用不会读 electron-flags，此时修改 `.desktop` 文件，路径一般为：`/usr/share/applications/`。在 Exec 中修改：

```shell
Exec=/usr/bin/code --force-device-scale-factor=2 %F
```

## 更换内核

```shell
paru -S linux-zen linux-zen-headers
```

修改 `/etc/default/grub`：

```shell
GRUB_DISABLE_SUBMENU=y
```

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

重启确保没有错误后可以删除原内核：

```shell
paru -Rsn linux linux-headers
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 禁用 GRUB 倒计时

```shell
sudoedit /etc/default/grub
```

修改配置文件：

```shell
GRUB_TIMEOUT=-1
```

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 主题

### GTK

对于 GTK，安装 `lxappearance` 以切换主题：

```shell
paru -S lxappearance
```

然后安装主题，这边推荐 `tokyonight`（主要是 `catppuccin-gtk` 已不再维护）：

```shell
paru -S tokyonight-gtk-theme-git
```

进入 lxappearance 切换主题：

```shell
lxappearance
```

### QT

QT 建议使用 `kvantum` 进行管理；

```shell
paru -S kvantum
```

然后添加环境变量：

```shell
set -gx QT_STYLE_OVERRIDE kvantum
```

安装主题：

```shell
paru -S kvantum-theme-catppuccin-git
```

使用 `kvantummanager` 管理主题：

```shell
kvantummanager
```

### fcitx5

fcitx5 的用户配置路径在 `.local/share/fcitx5/themes` 文件夹下，这边推荐 [catppuccin](https://github.com/catppuccin/fcitx5)。

根据文档安装即可：

```shell
git clone https://github.com/catppuccin/fcitx5.git
mkdir -p ~/.local/share/fcitx5/themes/
cp -r ./fcitx5/src/* ~/.local/share/fcitx5/themes
```

然后使用 fcitx5 配置工具进行配置：

```shell
fcitx5-configtool
```

### sddm

依然推荐 catppuccin。

```shell
paru -S catppuccin-sddm-theme-mocha
```

这个包已经亲切地安装了相应的依赖，因此我们只需要修改 sddm 配置文件即可。

```shell
printf "\n[Theme]\nCurrent=catppuccin-mocha\n" | sudo tee -a /etc/sddm.conf
```

如果要启用缩放：

```shell
printf "\n[Wayland]\nEnableHiDPI=true\n[X11]\nEnableHiDPI=true\n[General]\nGreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192\n" | sudo tee -a /etc/sddm.conf
```

### grub

```shell
paru -S catppuccin-mocha-grub-theme-git
```

然后编辑 `/etc/default/grub`，新增或修改以下行：

```shell
GRUB_THEME="/usr/share/grub/themes/catppuccin-mocha/theme.txt"
```

然后更新 grub：

```shell
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## steam

```shell
paru -S steam
```

如果想要静默启动，执行：

```shell
steam -nochatui -nofriendsui -silent
```

对于 Linux，建议使用 proton-ge，并在兼容性设置中选择：

```shell
paru -S proton-ge-custom-bin
```

### 对于 ntfs 文件系统

一般建议使用 ext4 或 btrfs 等文件系统存放游戏文件，因为 ntfs 上的 steam 库并非开箱即用的。但通过一定设置，它是可以正常使用的。

1. 安装 ntfs-3g

```shell
paru -S ntfs-3g
```

2. 获取 uuid：

```shell
sudo blkid /dev/<your disk> | awk '{print $3}' | awk -F'"' '{print $2}'
```

3. 写 fstab

```shell
sudoedit /etc/fstab
```

新增以下内容，填写上面获取到的 uuid：

```shell
UUID=<your uuid> /media/d lowntfs-3g uid=1000,gid=1000,rw,user,exec,umask=000 0 0
```

4. 重启；

```shell
reboot
```

5. 如果不起作用，链接本地的 compatdata 到库的 steamapps 文件夹

```shell
ln -s /<local steam path>/steamapps/compatdata /<remote steam path>/steamapps/
```

其中，本地 steam 文件夹路径一般为 `~/.steam/root`

另外，由于驱动的原因，ntfs 有时会被搞脏，产生只读无法写的情况，此时需要使用 `sudo ntfsfix /dev/nvme1nx` 进行修复。如果遇到 ntfsfix 无法修复的情况，尝试登录到 windows 使用 `chkdsk` 进行操作，如：

```shell
chkdsk c: /f
chkdsk d: /f
```

## 其他

### 跳过 validity check

对于一些 SHA256 错误的包，可以使用以下 flag 跳过验证（保证安全的前提下）：

```shell
paru -S --mflags --skipinteg
```
