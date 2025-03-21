---
title: 基于uv的pypi打包流程
created: 2025-03-05 22:33:45
---

python包打包大致分为两步：构建和发布。而一些包管理器，如`poetry`或是`uv`，都提供有打包的快捷操作，让发布pypi变得十分容易。

## 构建

对于使用`uv init`创建的python项目，一般已经有了一个合法的项目结构，此时需要修改`pyproject.toml`，填写一些必要信息：

```shell
[project]
name = "ffmpegx"
version = "0.1.0"
description = "A wrapper of ffmpeg"
readme = "README.md"
authors = [{ name = "levinion", email = "levinnion@gmail.com" }]
requires-python = ">=3.13"
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

可以看到这里的`hatchling`就是uv当前所使用的构建系统后端。开始构建：

```shell
uv build
```

目标文件会放在`dist`目录下。

## 发布

在[pypi](https://pypi.org/)上注册一个帐号，并且创建API TOKEN。

然后进行发布：

```shell
uv publish
```

用户名填写`__token__`，密码填写上面生成的token即可。