---
title: platformio与arduino环境
created: 2025-04-01 23:38:46
---

## 前言

arduino有一个cli工具：`arduino-cli`，可以简单地进行项目初始化、编译等工作，但LSP不尽如人意，很难利用clangd获取提示，遂放弃，并选择platformio搭配arduino使用。

platformio是一个平台，大概是目前支持嵌入式设备种类最多、社区最活跃的了。它本身在vscode上有一个图形界面（IDE），但在vim上，有`platformio-core`就足够了。

## 安装

```shell
sudo pacman -S platformio-core platformio-core-udev
```

其中后者提供了udev规则，解决了访问某些设备端口的权限问题。

## 初始化

```shell
mkdir pio-example
cd pio-example
git init

pio project init --board <board-id> --ide <ide>
```

这里我们创建一个文件夹，并进行初始化，这将创建一个基本的项目模板。

如果不清楚板子的id，可以执行`pio devices`列出全部支持的设备ID，并使用`grep`或`rg`进行检索。

以我的luatos esp32s3举例，将使用下面的ID创建项目：

```shell
pio project init --board esp32-s3-devkitc-1 --ide vim
```

## 修改platformio.ini

如果是platformio原生支持的开发板，可以跳过这一步。如果不是，我们需要使用一个通用ID进行初始化，并且手动覆盖一些参数：

```ini
[env:esp32-s3-devkitc-1]
platform = espressif32
board = esp32-s3-devkitc-1
framework = arduino
board_upload.flash_size = 16MB
board_build.f_cpu = 240000000L
monitor_speed = 115200
upload_speed = 256000
build_flags = -DBOARD_HAS_PSRAM
board_build.arduino.memory_type = qio_opi
extra_scripts = pre:./build/build.py
```

如果不清楚具体参数，可以上[platformio社区](https://community.platformio.org/)查找或提问。

## 编译

在`src/`目录下创建一个`main.cpp`文件：

```cpp
#include "Arduino.h"

void setup() {

}

void loop() {

}
```

然后就可以编译并烧录到板子上：

```shell
pio -f -c vim run --target upload
```

或者使用以下命令进行监听：

```shell
pio device monitor
```

## clangd设置

整个环境配置最难的大概就是配置clangd了。

### compile_commands.json

首先，我们需要让platformio生成一份`compile_commands.json`。

```shell
pio run -t compiledb
```

这将在项目根目录（与`platformio.ini`同级）下生成一份`compile_commands.json`文件。nvim默认检索`compile_commands.json`的路径也就是根目录；但如果你修改过这个路径，将它移到对应目录中去。或者我们也可以通过`extra scripts`：

```shell
extra_scripts = pre:build.py
```

对于`build.py`：

```python
import os

Import("env")

env.Replace(COMPILATIONDB_INCLUDE_TOOLCHAIN=True)

env.Replace(COMPILATIONDB_PATH="build/compile_commands.json")
```

然后重新运行`pio run -t compiledb`，就会生成在`build/`目录下。

### 解决报错

现在，当引入`Arduino`时会遇到clangd报错，但因为编译能够通过，所以我们直接忽略这些错误就好。创建一个`.clangd`文件：

```
CompileFlags:
  Add: [
    -ferror-limit=0
  ]
  Remove: [
    -fno-tree-switch-conversion,
    -mlongcalls,
    -fstrict-volatile-bitfields,
  ]
Diagnostics:
  Suppress: "no_member"
```

当我们选择忽略一些编译选项后，会提示`too many errors`，这时我们添加`-ferror-limit=0`以禁用错误数量限制，也就不会报错了。对于其他一些诊断问题，在`Suppress`中添加禁用就好。

clangd默认参数可以参考；

```shell
"clangd",
"--clang-tidy",
"--all-scopes-completion",
"--completion-style=detailed",
"--header-insertion=iwyu",
"--pch-storage=disk",
"--log=error",
"--j=12",
"--background-index",
"--function-arg-placeholders",
"--fallback-style=llvm",
"--query-driver=**",
"--suggest-missing-includes",
"--cross-file-rename",
"--header-insertion-decorators",
```



