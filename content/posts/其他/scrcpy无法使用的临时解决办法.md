---
title: scrcpy无法使用的临时解决办法
created: 2025-12-17 14:52:34
---
在升级内核到6.18后，scrcpy无法启动窗口。于是使用adb作为临时替代方案。

## 显示

scrcpy解决的第一件事是显示画面，而这可以通过`screencap`命令来完成：

```shell
adb -s localhost:5555 shell screencap -p | magick - sixel:-
```

这将画面传输到本地并转换为sixel格式在终端模拟器输出。

如果想要视频效果：

```shell
while true; do
    printf "\033[H"
    adb -s localhost:5555 exec-out screencap -p | magick - sixel:-
done
```

或是使用`ffplay`：

```shell
while true; do
    adb -s localhost:5555 exec-out screencap -p
done | ffplay -
```

## 启动应用

要启动一个应用，可以使用`am start`，命令格式如下：

```shell
adb shell am start -n com.package.name/com.package.name.ActivityName
```

它接受两个参数，分别是包名和活动名，以`/`分隔。

可以使用以下命令以列出第三方应用包名：

```shell
adb -s localhost:5555 shell pm list packages -3
```

然后在以下命令输出结果中查找活动名：

```shell
adb -s localhost:5555 shell "dumpsys package com.bilibili.azurlane"
```

该活动名的`Action`属性应为：`android.intent.action.MAIN`

于是可以通过以下命令拉起应用：

```shell
adb -s localhost:5555 shell am start -n com.bilibili.azurlane/com.manjuu.azurlane.MainActivity
```

## 互动

如果需要与模拟器互动，可能并不是那么方便，我们只能手动触发事件。

如果要发送点击事件：

```shell
adb -s localhost:5555 shell input tap 700 500
```