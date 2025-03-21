---
title: Windows调教指南
created: 2024-12-27 20:01:00
---
## 前言

凡是接触过 Linux 或是 Macos 等系统的人，大多都会对系统有些洁癖，或是养成一些使用操作系统的习惯。无论是以任何理由再次回到 Windows，这些习惯会则会成为阻碍，因为 Windows 向来不是一个开放的系统。近些年，Windows 的 UI 有所改善，但使用逻辑以及效率却似乎一年不如一年。为了让人能够更加平顺地过渡到 Windows，为了使那些正在使用 Windows 的人能够更舒适地使用 Windows，也就是我撰写本文的意义所在。

## 一个整洁的任务栏

微软的默认任务栏是臃肿的，包含各种用不到的功能，甚至广告。好在它比较容易整顿，我们需要右键任务栏进入任务栏设置，把能关的选项通通关掉，这包括：

- 隐藏搜索框
- 关闭小组件

## 输入法设置

默认的微软输入法已经具有较好的体验，但对于小鹤双拼用户来说很难说是友好，因为它并没有一个预设的小鹤双拼方案。需要通过修改注册表实现

1. Win + R：Regedit（注册表编辑器）
2. 进入 `HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS`
3. 新建字符串值，名称为 `UserDefinedDoublePinyinScheme0`，值为 `小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt`

或者在 cmd 执行：

```batch
reg add HKEY_CURRENT_USER\Software\Microsoft\InputMethod\Settings\CHS /v UserDefinedDoublePinyinScheme0 /t reg_sz /d "小鹤双拼*2*^*iuvdjhcwfg^xmlnpbksqszxkrltvyovt"
```

## 原始的右键菜单

Win11新的右键菜单虽然优化了ui，但是隐藏了许多内容，导致效率降低，以下命令能够恢复原始的右键菜单：

```batch
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
taskkill /F /IM explorer.exe
explorer.exe
```

如果想要恢复成Win11的右键菜单，执行：

```batch
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
taskkill /F /IM explorer.exe
explorer.exe
```

## 启用 UTC

Windows默认使用RTC（Real-Time Clock），而如果是多系统，则其它系统（Linux）使用UTC（Universal Time Coordinated），可能导致系统时间出现错乱，一般执行以下命令修改注册表以启用 UTC ：

```powershell\
Reg add HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1
```

## 永久关闭快速启动

```powershell\
Reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System /v HiberbootEnabled /t REG_DWORD /d 0
```
## WSL

### 安装

对于习惯在 Linux 下工作的人来说，WSL 是必要的。

在安装前，需要确保适用于 Windows 的 Linux 子系统和虚拟机平台已开启。开始菜单进入“启用或关闭 Windows 功能”，勾选 Windows 的 Linux 子系统和虚拟机平台。如果有虚拟机需求，也可以勾选启用 Hyper-V，当然这不是必须的。

cmd 中运行 `wsl --install` 即可安装默认的 Ubuntu 发行版，`wsl --install -d` 可以显式指定要安装的发行版，如 Debian。

对于不受支持的发行版，如 Arch，可以查看以下项目：[ArchWSL](https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/)

### 使用 Windows 字体

执行以下命令以在 WSL 中访问 Windows 系统下的字体：

```bash
sudo mkdir /usr/share/fonts/
sudo ln -s /mnt/c/Windows/Fonts /usr/share/fonts/font
fc-cache -fv
```

## 快捷键

Windows 有着一组快捷键的预设值，而且无法修改。特别是 Win 键，其位置较好，非常适合作为 Meta 键使用，但是其绑定的快捷键只有部分会使用到，并且很难重设，因此自定义困难。AutoHotkey 能够重新绑定 Win 键，且功能成熟，但由于其常被用作脚本外挂，因此有被红信的风险。

好在 Powertoys 提供了 Keyboard Manager 工具，能够实现改键功能，或是执行脚本。基于此，我们可以摆脱讨厌的 Win 键，将其用作 Meta 键以执行自定义指令。但是，这仍有局限。在 Win10 上，一切似乎运行正常；在 24H2 上，即使经过改键，仍然可能会弹出开始菜单。

那么使用 Alt 又如何呢？一切似乎都很棒，但是如果你使用 blender 或是 ps 等等，alt 绑定其他键就成了一场灾难。目前我的解决措施是使用 `Alt+Ctrl+Shift` 作为 Meta 键。是的，你没有看错。如何一键发送三个键位？我使用 wooting 的 dks，而你需要一把支持 dks 的磁轴键盘（doge）。

### 窗口

Windows 自带的快捷键实现了部分窗口控制能力，如 alt+f4 关闭窗口等，但其他窗口控制，如最大化、最小化并未实现，且 alt+f4 并非对所有窗口都有效。因此我基于 winapi 写了个工具包，实现了一些包括窗口和虚拟桌面控制的基本命令：[wtools](https://github.com/levinion/wtools)


