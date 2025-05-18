---
title: 使用just创建一个cli？！
created: 2025-01-07 20:01:14
---
## 前言

Just 是一个类似于 Make 的 command runner，但和 Make 不同，它并不希望成为一个复杂的构建工具。相反，Just 提供了一种非常人体工学的命令创建方式，相比 Make 也更容易上手，并且能实现一些意想不到的功能（比如创建一个 cli）。

## 基础

```justfile
run:
    echo "hello world"
```

一个最简的 justfile 大概如上面所示，到此为止似乎和 Makefile 没什么不同，我们只需像执行 Makefile 一般执行它；

```shell
❯ just # or just run
echo "hello world"
hello world
```

嫌啰嗦可以这样：

```justfile
run:
    @echo "hello world"
```

它会省略掉执行的命令本身：

```shell
❯ just
echo "hello world"
hello world
```

### 子命令及参数

```justfile
run:
    @echo "hello world"
version:
    @echo v0.1.0
```

我们可以指定子命令运行，比如上面的 justfile，我们可以运行 `just version`，结果如下：

```shell
❯ just
v0.1.0
```

另外也可以很简单地声明参数，并使用 `{{}}` 填充（和 rust 很像）：

```justfile
run comment:
    @echo {{comment}}
```

```shell
❯ just run "hello world"
hello world
```

### 递归调用

我们可以使用如下方式，在执行 b 命令之前，先执行 a 命令：

```justfile
b:a
    @echo hello b
a:
    @echo hello a
```

```shell
just
hello a
hello b
```

但是这种方式有一定缺点，如只能前向依赖、无法传递参数等，因此一般多使用递归调用的方法。下面 justfile 的执行结果与上面完全一致。

```justfile
b:
    @just a
    @echo hello b
a:
    @echo hello a
```

## 写一个 cli

cli 是什么？cli 是一个接口，它接受一定参数，并达到我们期望的结果。对于常在终端下工作的人来说，当我们开发一个程序，为了调试，第一时间是写一个 cli。对于任何语言来说，cli 都通常是嵌入在程序项目的，我们需要定义 cli 的子命令、参数、标志，并且完成相应的逻辑。但是，这不会太麻烦了吗？特别是对于一个 bash 脚本来说，这需要一个 switch，还要处理参数的传入。

幸运的是，我们可以使用 justfile 快速创建一个 cli，甚至可以指定使用什么执行脚本：

```justfile
set shell:= ["fish","-c"]
run:
    # do something here
other:
    # do other things here
```

但是，它仍然只能在本目录下执行，否则就必须使用 `--justfile` 来指定。这就需要用到 `#!` 了。

```justfile
#!/usr/bin/just --justfile
set shell:= ["fish","-c"]
run:
    # do something here
other:
    # do other things here
```

`chmod +x` 后，将我们的文件放到任意一个在 Path 中的目录，然后就能愉快地运行了。
