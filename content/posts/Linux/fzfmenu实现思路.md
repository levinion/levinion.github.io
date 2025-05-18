---
title: fzfmenu实现思路
created: 2025-02-15 14:48:25
---
app launcher 的模型很简单，基本就是一个输入框加上一个列表。使用比较多的 app launcher，像是 rofi，虽然灵活快速，但是难以定制。受到这篇帖子鼓舞：[using_fzf_as_a_dmenurofi_replacement](https://www.reddit.com/r/commandline/comments/jatyek/using_fzf_as_a_dmenurofi_replacement/)，决定用 fzf 代替 rofi 实现一个 app launcher，同时支持一些基本的操作。

fzf 是一个模糊搜索工具，但是只支持终端，因此需要搭配像是 alacritty 这样的终端来使用。界面很美观，而且支持定制，同时支持 bind 操作调用脚本和获取用户输入，因此具备了一切 app launcher 需要的元素。

## 界面

GUI 使用 alacritty 提供。alacritty 支持通过 `--class` 参数设置窗口类型，因此搭配 i3 可以获得我们想要的窗口样式，比如：

```shell
for_window [class="fzfmenu"] floating enable, resize set height 400, resize set width 1200, move position center, focus
```

以上操作分别是：对于类型为 fzfmenu 的窗口，启用浮动功能（也就是类堆叠），将尺寸调整为 `1200x400`,居中，聚焦。

fzf 同样可以进行主题定制，添加以下环境变量以启用 `catppuccin` 主题：

```shell
set -Ux FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"
```

## 实现逻辑

首先是最重要的命令：

```python
path = os.path.realpath(__file__)
subprocess.call(
    [
        "fish",
        "-c",
        f"alacritty \
        --class fzfmenu \
        -e fish -c \
        \"fzf \
        --bind 'start,change:reload:python {path} picker {{q}}' \
        --bind 'enter:become(nohup python {path} run {{}} > /dev/null 2>&1 &)'\" \
        ",
    ]
)
```

在这里，我们规定了 alacritty 的窗口类型，以在 i3 中设置它的窗口样式。

`--bind 'start,change:reload:python {path} picker {{q}}'` 设置了在 fzf 启动和输入发生改变时重新运行该命令。其中 `{path}` 是该脚本的路径，此处可忽略。该脚本的标准输出即为 fzf 上显示的选项。

`--bind 'enter:become(nohup python {path} run {{}} > /dev/null 2>&1 &)'` 设置了在选择项目后运行的命令。由于脚本运行结束后 alacritty 终端窗口自动关闭，因此需要使用 nohup，并将标准输出重定向到 `/devnull` 当中。此处的 `{}` 即为选中项目的字符串结果，将其传入脚本中以运行。

由于这只是个简单的脚本，不想分成太多的文件，因此按照如下方式做判断，从而进行递归调用：

```python
def main():
    argv = sys.argv
    if len(argv) == 1:
        call_fzf()
    else:
        if argv[1] == "picker":
            run_plugins_picker(" ".join(argv[2:]))
        elif argv[1] == "run":
            run_plugins(" ".join(argv[2:]))

```

在 `run_plugins_picker` 函数中，根据输入的前缀判断该启用哪个插件：

```python
def run_plugins_picker(input: str):
    if input.startswith("wd "):
        window_jump_picker(input)
    elif input.startswith("kl "):
        killer_picker(input)
    else:
        open_applicaton_picker(input)
```

由于不想要多个插件同时启用从而影响性能和干扰选择，因此只允许同一时间启用一个插件。

然后对于每个插件内部，使用两个函数定义插件逻辑：

```python
def killer_picker(input: str):
    input = input.lstrip("kl ")
    if len(input) == 0:
        return
    output = (
        subprocess.check_output(["bash", "-c", f"pgrep -fa {input}"]).strip().decode()
    )
    path = os.path.realpath(__file__)
    for line in output.splitlines():
        if path in line:
            continue
        print("kl " + line)

def killer_runner(output: str):
    pid = output.lstrip("kl ").split(" ")[0]
    subprocess.call(["bash", "-c", f"kill -9 {pid}"])

```

上面的插件可以根据输入列举出当前存在的进程，并且可以根据用户选择杀掉它。很简单但很实用的一个模式。在 `picker` 中，我们调用命令，并将存在的选项打印到标准输出中。

为什么要在输出前面加一个 `kl `？这就是 fzf 不灵活的一个地方，因为 fzf 只能根据传入的所有关键词进行模糊搜索，因此输入字符一定要包含在我们想要的结果中，否则无法被列出。

当用户选择后，递归调用了 `run_plugins` 函数，根据前缀选择执行 `killer_runner`。此处传输的 output 即为选择的内容。在 `picker` 中，我们打印了前缀 +`pgrep -fa xxx` 输出的内容，因此我们的 output 的内容格式如下：

```shell
kl 7755 alacritty
```

其中 `kl` 是插件前缀，`7755` 是进程 pid，`alacritty` 是进程名称。

因此对于创建一个插件，有以下步骤：

1. 新建 `plugin_name_picker(input: str)` 函数，列举所有表单选项；
2. 新建 `plugin_name_runner(output: str)` 函数，确定具体执行逻辑；
3. 将上面两个函数分别补充到 `run_plugins_picker` 以及 `run_plugins` 函数中。

后续如果需要改进，大概就是可以将插件抽象出来，分散到独立文件中，并且在主函数中实现插件的读取了。但就当前来说，目前的代码已经足够实现我的需求了。
