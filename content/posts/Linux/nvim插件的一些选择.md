---
title: nvim插件的一些选择
created: 2025-06-19 16:32:43
---
最近放弃了LazyVim，决定从头开始搓自己的配置。虽然花了约一天的时间，但其实难度并不高，时间主要花在了插件的选择上。本文主要讨论：一个像LazyVim那样成熟，但又足够精简的nvim配置大概需要哪些插件。

## 插件管理器

虽然我认为在zsh中，插件管理器可以被系统包管理器代替，因此没有什么作用，但这在nvim中就就不太一样了。nvim需要的插件更多，并且严重依赖懒加载以提高加载速度（相比之下，zsh只需要p10k就好）。因此一个方便且能提供懒加载的包管理是很有必要的，这也就是我为什么选择[lazy.nvim](https://github.com/folke/lazy.nvim)的原因。另外，它也是LazyVim使用的插件管理器，而且同样出自[folke](https://github.com/folke)之手。

其他插件管理器的选择包括：

- [vim-plug](https://github.com/junegunn/vim-plug)，这是一个超级老牌的插件管理器，星数也是最多的
- [packer.nvim](https://github.com/wbthomason/packer.nvim)：虽然有8k星，但是处于无人维护状态，因此不推荐使用
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)：packer.nvim的继任者，只有300+星，见仁见智

## 主题

主题这边就很个性化了，lazy.nvim的默认配置中所提供的主题[tokyonight](https://github.com/folke/tokyonight.nvim)，是一个不错的选择。为什么lazy.nvim会使用这个主题呢，~~因为它同样出自folke~~。

我使用的主题是[catppuccin-mocha](https://github.com/catppuccin/nvim)，因为我喜欢catppuccin的配色。

nvim本身也带了不少颜色方案，这可以通过`:colorschema <主题名称>`启用。

## 选项

选项严格意义上不算插件，但它太重要了，因此在这边提一嘴。nvim的默认选项很多是不合理的（个人观点），虽然对轻度编辑（改改配置文件之类的）没有太大影响，但对写代码这种对编辑器要求比较高的场合就很难受了。因此需要修改不少选项来获得相对良好的体验。

下面是我修改的一些选项：

```lua
vim.g.mapleader = " "        -- set leader with <Space>
vim.g.maplocalleader = "\\"
vim.g.snacks_animate = false -- disable animation provided by snacks

local opt = vim.opt
opt.spell = false             -- disable spell
opt.swapfile = false          -- disable swapfile
opt.clipboard = "unnamedplus" -- sync clipboard with system
opt.expandtab = true          -- use space instead of tab
opt.tabstop = 2
opt.shiftwidth = 0            -- use 2 spaces instead of 4
opt.confirm = true            -- confirm before exit an editing buffer
opt.cursorline = true         -- highlight currentline
opt.number = true             -- show line number
opt.relativenumber = true     -- use relative line number
opt.wrap = false              -- disable wrap
opt.autoread = true           -- auto reload if file changed
opt.ignorecase = true         -- ignore case when searching
opt.smartcase = true          -- don't ignore case with capitals
opt.undofile = true           -- use undo file to save undo history
opt.undolevels = 10000        -- set undo level to a big value
opt.signcolumn = "yes"        -- always open signcolumn
```

其中比较重要的是undofile和undolevels。undofile也就是在磁盘上保存当前编辑状态，从而允许在关闭当前buffer后仍然能找到之前的编辑操作，从而进行撤回。undolevels默认为1，也就是只允许撤回一次，当再次撤回时它就提示已经是最新了（？），因此在这设置一个很大的值即可。

## 代码补全和格式化

代码补全和格式化是编辑器很重要的一环，这边需要设置的东西挺多，因此分开来讲

### 代码补全

[mason.nvim](https://github.com/mason-org/mason.nvim)是最常用的LSP、Linter等的管理工具，可以很方便地安装、更新和卸载LSP。它常搭配[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)和[mason-lspconfig](https://github.com/mason-org/mason-lspconfig.nvim)使用。

nvim-lspconfig的作用是为已经安装的LSP提供一套合理的默认配置，从而能满足大部分人的需求并且开箱即用。也可以用自定义配置来覆盖它的默认配置，以满足一些个性化需求。比如我的clangd配置如下：

```lua
lspconfig.clangd.setup {
        cmd = {
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
        },
        init_options = {
          compilationDatabasePath = "./build",
        },
      }
```

mason-lspconfig相当于是mason.nvim和nvim-lspconfig中间的桥梁。它对mason中lsp的名称进行转换以和nvim-lspconfig中的一致。比如，在mason.nvim中有名为`lua-language-server`的LSP，但它在nvim-lspconfig中的名称则是`lua_ls`。

然后，你还需要[blink.cmp](https://github.com/Saghen/blink.cmp)，它将LSP的提示以列表的形式呈现到界面上。[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)是在blink.cmp出现之前最常用的补全插件，但blink.cmp的性能要比它好得多。

### 格式化

格式化常用[conform.nvim](https://github.com/stevearc/conform.nvim)。启用format_on_save后即可在保存时自动格式化：

```lua
return {
  'stevearc/conform.nvim',
  opts = {
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
  },
}
```

或者使用`:lua vim.lsp.buf.format()`自行格式化。

### Linter

另外一个是Linter，实际使用得比较少，一般使用的插件是[nvim-lint](https://github.com/mfussenegger/nvim-lint)。

### DAP

DAP我不用，所以就让我们跳过这部分吧。（打断点我有gdb）

## 文件管理

核心插件大概就是以上这些，接下来的都是一些不必需，但能极大程度上提高编辑体验的插件。

nvim中的文件管理同在桌面上使用文件管理器的使用场景不太相同。它的使用场景主要集中在：

- 项目内文件的切换，或者说search
- 文件和目录的基本操作：rename、delete、create

因此最好搭配不同插件来分别适配这两种环境。

### 文件切换和搜索

在终端中经常将fzf、fd、ripgrep这几个cli工具搭配使用来进行文件/内容搜索，针对层数不多的目录特别好用。在nvim中一般有以下几个插件都能提供类似的功能：

- [snacks.picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md)：snacks.nvim是folke编写的一系列插件的集合，涵盖了很多场景，后面我们还会看到它。picker是它之中的一个选择器，界面美观，性能也不错，功能全面。
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim):telescope是这里面最老牌、star数最多，同时功能最全的，但相比其他两个插件性能可能略微逊色了点。
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)：fzf的lua实现，使用起来没什么问题，但可能功能没另外两个多。

### 文件操作

在进行操作时我们不可能退出去在终端去cp、mv、...（其实也不是不行），因此还是最好在nvim中做。常规的方式是基于树的，也就是普通文件管理器的方式，但更多地通过一些快捷键完成。另外还有一些特殊的，提出通过文本编辑的方式来进行文件管理（这很vim了），效率会更高一些。

#### 传统的

- [neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim)：比较老牌的树状文件管理器，类似vscode的文件树，没什么缺点，我用了很久。
- [snacks.explorer](https://github.com/folke/snacks.nvim/blob/main/docs/explorer.md)：又是snacks的小组件，它其实是picker伪装成的一个文件树。缺点可能是可定制性差了点，上面有个很丑（个人观点）的搜索框，但我没能找到怎么关闭。
- [yazi.nvim](https://github.com/mikavilpas/yazi.nvim)：将yazi内嵌在nvim的浮动窗口中，界面很好看，同时能够和yazi共用一套配置。搭配neo-tree用过一段时间，体验不错，但有了oil所以放弃了。

#### 特殊的

- [oil.nvim](https://github.com/stevearc/oil.nvim)：这是我目前在使用的插件。好处是文件管理操作类似普通的buffer，因此你可以在里面使用任何你自定义的快捷键。我一般使用`open_float`在浮动窗口中打开它。
- [mini.files](https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-files.md#demo)：mini的东西不会不好用。据传这是oil.nvim的更现代的替代品，但我没折腾明白它那个浮动窗口的逻辑，因此放弃。只能说是我不会用。

## 其他

其他就是一些比较零碎，但同样很有用的插件，这边就随便列列：

- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)：一个比较美观的状态栏，用来替代原先的黑框框
- [which-key.nvim](https://github.com/folke/which-key.nvim)：写到这边才发现这个插件应该提前或者单独开一个标题的。它能够即时地提示快捷键键位，在快捷键多的情况下尤其好用。
- [flash.nvim](https://github.com/folke/flash.nvim)：按s在屏幕上使用标签跳转，很方便。
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)：能够显示git diff，用git是必备的
- [todo_comments](https://github.com/folke/todo-comments.nvim)：高亮显示TODO等标签，还能结合其他插件进行搜索
- [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim)：可能略冷门，但相当好用的插件，对不同层次的括号添加不同颜色，方便找到没闭合或多余的括号（开发时很常见但头疼的场合）
- [mini.nvim](https://github.com/echasnovski/mini.nvim)：mini的插件集合，可以全部装也可以单独装。我目前只使用了mini.pairs（来自动匹配括号）和mini.ai（一些增强操作）
- [vim-suda](https://github.com/lambdalisue/vim-suda)：也就是提供了`:w !sudo tee % > /dev/null`同样的功能，但由于一些原因，该命令在nvim中无法奏效，见[Github Issue](https://github.com/neovim/neovim/issues/12103)。而用了这个插件至少能在nvim里输密码了。
- [barbecue.nvim](https://github.com/utilyre/barbecue.nvim)：今天才发现它已经像名字一样barbecue（archived）了，但是依然能用。作用是在编辑器顶部显示一个顶栏，提示一下代码层次（和vscode那样）。要说有用还真没什么用，更多地是一个装饰作用。






