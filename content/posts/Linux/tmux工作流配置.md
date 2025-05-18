---
title: tmux工作流配置
created: 2025-03-05 23:11:53
---
## 为什么是 tmux

终端复用器主流的选择大概只有两个：tmux 和 zellij。zellij 相对更新一点，配置更容易上手，并且有一个相对好用的键位提示（~~更重要的是，它是用 Rust 写的~~）。那么为什么选 tmux？

zellij 很好用，但其缺点在于插件系统。相比 tmux，zellij 的生态更差，这也是所有新项目的一个通病，它的生态需要时间积累。另外，相比 tmux 配置和插件所采用的类 shell 语法，zellij 的 wasm 上手门槛更高。我曾经也尝试过使用 rust 编写插件，但导致 zellij 罢工（真的是一个非常简单的插件，它只在插件加载时创建一个 tab），因此放弃了。而且，tmux 的配置比预想更加灵活简单。

## 基础选项

### 颜色

默认的颜色选项可能会导致一些 TUI 界面，如 neovim 等变得很奇怪，因此添加以下配置：

```shell
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

### 启用鼠标

```shell
set -g mouse on
```

添加以上选项后就可以使用鼠标切换焦点和滚动屏幕。

### vi mode

```shell
set -g mode-keys vi
set -g status-keys vi
```

这样就可以在命令模式中使用 vi 快捷键进行操作。

### 将会话与窗口关联

会话会在窗口关闭时自动销毁，这对于不想打开很多会话很有用：

```shell
set -g destroy-unattached on
```

## 键位

如果不想学习默认键位，并且想要自己配置，完全可以解绑所有默认键位（less is more），并且确保设置了快捷键前缀：

```shell
unbind -a
set -g prefix C-b
```

最简单的命令大概像这样，这时按 t 键就能创建一个新的标签页：

```shell
bind-key t new-window
```

而这等同于：

```shell
bind-key -T prefix t new-window
```

tmux 的键位表有一个分组的概念，相当于 VIM 中的模式。默认的模式为 `root`。如果我们想要连续执行多个命令却不想要敲很多次前缀：

```shell
bind-key h previous-window \; switch-client -T prefix
```

`;` 为命令的分隔符，需要转义（不清楚原因），使用这种方式可以将多个命令绑定到一个键位。在前面一条命令结束后，会自动将模式切换到 `root`，而 `switch-client -T` 可以显式切换当前模式，取代了按前缀的工作。

而这个分组比起 zellij 灵活在它可以自定义，下面就定义了一个自定义分组 `group`：

```shell
bind-key g switch-client -T group
bind-key -T group h select-window -t 0
```

这允许我们按 `<prefix>gh` 切换到第一个标签页（灵感来源于 helix 的键位）。

其他就是一些常用操作的键位设置：

```shell
bind-key t new-window
bind-key h previous-window \; switch-client -T prefix
bind-key l run "python ~/.config/tmux/scripts/next-window.py" \; switch-client -T prefix
bind-key j select-pane -t +1 \; switch-client -T prefix
bind-key k select-pane -t -1 \; switch-client -T prefix
bind-key x kill-pane\; switch-client -T prefix
bind-key v split-window -h 
bind-key V split-window -v
bind-key q kill-session
bind-key r source-file "~/.config/tmux/tmux.conf" \; display "tmux config reloaded"
bind-key : command-prompt
bind-key ? list-keys
bind-key f display-popup -b none -E "python ~/.config/tmux/scripts/fzf.py"
```

## 外观

对于外观，可以搜索下 tmux 主题，找到自己喜欢的主题，根据 README 进行配置即可。tmux 没有模式指示，因此显示当前是否按下 prefix 会是个好主意。一些插件提供了这一功能，但 tmux 本身也支持，只需设置以下选项：

```shell
set -g status-right '#{?client_prefix,#[reverse]<Prefix>#[noreverse] ,}"#{=21:pane_title}"'
```
