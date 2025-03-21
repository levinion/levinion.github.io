---
title: WSL下的esp-idf开发环境配置（使用nvim）
created: 2025-01-01 19:54:00
---
## 前言

最近想要玩玩吃灰很久的 esp32s3 单片机，于是着手搭建开发环境。官方的[文档](https://docs.espressif.com/projects/esp-idf/zh_CN/v5.3.2/esp32/get-started/)几经比较完善，但是由于个人开发习惯，使用 wsl 以及 nvim，踩坑点比较多，因此简单记录下。

写文章时所使用的具体环境如下：
- 发行版：Archlinux（ArchWSL）
- Shell：fish
- 单片机：esp32s3
- 编辑器：nvim
- LSP：clang（实际需要替换成 esp-clang，下文会讲到）

## 安装

本人使用的发行版是 Arch，其他发行版可借鉴下，或是直接查阅文档。

1. 安装必要的依赖：

```shell
sudo pacman -S --needed gcc git make flex bison gperf python cmake ninja ccache dfu-util libusb
```

2. 安装 esp-idf，由于 aur 已经有打好的包，因此比较轻松：

```shell
sudo paru -S esp-idf
```

3. 设置工具。aur 安装的工具链路径在 `/opt/esp-idf` ：

```shell
/opt/esp-idf/install.fish esp32s3
```

如果使用 bash 或 zsh，将 .fish 替换成 .sh 即可。esp32s3 可根据需要替换成自己的板子型号。

4. 开发esp32程序前需先导入环境变量，在终端加入类似：

```shell
alias get_idf ". /opt/esp-idf/export.fish"
```

## 开发前的准备

### 引入环境变量

使用我们上面创建的别名：

```shell
get_idf
```

### 创建项目

虽然官方文档让我们从模板创建工程，但实际上，`idf.py` 提供了一个 `create-project` 命令，可以简单地创建一个项目。

```shell
idf.py create-project <Project Name>
```

### 设置 target

```
idf.py set-target esp32s3
```

默认 target 为 esp32，注意替换成自己的板子型号
### .clangd

我们需要在项目根目录下创建一个 clangd 配置文件以解决一些头文件错误。

```.clangd
CompileFlags:
  Remove:
    [
      -fno-tree-switch-conversion,
      -fno-shrink-wrap,
      -mtext-section-literals,
      -mlongcalls,
      -fstrict-volatile-bitfields,
      -march=rv32imac_zicsr_zifencei,
    ]
```

### 编辑器

如果你使用 VSCode，到这一步大概可以愉快地开发了。

```shell
code .
```

但是 nvim 则不然，需要一些额外的配置，这就是我们后面的主要工作。

## nvim 配置


### compile_commands.json

clang 需要一个 `compile_commands.json` 文件才能正确工作，正常情况下，cmake 会自动在 build 目录下生成该文件。

```shell
mkdir build
cd build
cmake ..
```

nvim 比较不智能的一点是无法处理不在根目录的 `compile_commands.json` 文件，解决方法大致有三种。一是将 build 目录下的文件复制到根目录，二是建立符号链接，第三种则是修改 nvim 的 clang 配置。

```lua
init_options = {
  compilationDatabasePath = "./build",
},
```

为了让 nvim 正确识别项目根目录，`.git` 似乎是必要的。

```shell
git init
```

### 使用 esp-clang/clangd 而非 clangd

即使我们正确引入了环境变量，但是 freertos 等组件的头文件仍无法正确导入，这是因为 esp 工具链不使用标准的 clang。为此，我们需要获取 `esp-clang`。

```shell
idf_tools.py install esp-clang
```

下载到的默认路径类似 `HOME/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd`, 然后我们替换 nvim 使用的 lsp 命令即可：


```lua
cmd = {
          "$HOME/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd",
          "--clang-tidy",
          "--all-scopes-completion",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--pch-storage=disk",
          "--log=error",
          "--j=5",
          "--background-index",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
```

这有个问题，为了只开发 esp 时使用 `esp-clang`，我们还需要实现按需导入，因此完整配置如下：

```lua
local clangd = "clangd"

if os.getenv("IDF_PATH") then
  clangd = "$HOME/.espressif/tools/esp-clang/16.0.1-fe4f10a809/esp-clang/bin/clangd"
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          clangd,
          "--clang-tidy",
          "--all-scopes-completion",
          "--completion-style=detailed",
          "--header-insertion=iwyu",
          "--pch-storage=disk",
          "--log=error",
          "--j=5",
          "--background-index",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          compilationDatabasePath = "./build",
        },
      },
    },
  },
}
```

## 最后

现在你可以使用 nvim 创建、编写甚至编译 esp32 项目，但是你无法通过 wsl2 进行烧录，这是因为 wsl2 不支持 usb 设备连接！幸好我们有 [usbipd-win](https://github.com/dorssel/usbipd-win) 项目，具体的操作文档可以参见[连接 USB 设备](https://learn.microsoft.com/zh-cn/windows/wsl/connect-usb)。

但是 `usbipd-win` 只是一个后端，它无法自动地将 usb 设备共享至 wsl，这时候就有了 [wsl-usb-gui](https://gitlab.com/alelec/wsl-usb-gui#wsl-usb-gui)。它为 `usbipd-win` 提供了一个前端，并且允许我们为 wsl 自动连接 usb 设备。

一切准备就绪，就可以开始烧录了。

```shell
idf.py flash monitor
```

然后使用 `ctrl + ]` 退出监视器。
