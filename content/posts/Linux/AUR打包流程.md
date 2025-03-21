---
title: AUR打包流程
created: 2025-01-06 23:51:31
---
## 前言

使用 AUR 已经有些年了，一直在用社区包，却从未自己打过包。这次因为写了个觉得还算好用的小工具，觉得不妨打个包试试，于是尝试了一番，并于本文记录下。

## 准备

在打包之前，需要先准备好文件。本次打包的项目很简单，只有一个二进制可执行文件，因此把它拷贝到 build 目录，并添加到压缩包准备上传。

```shell
mkdir build
cp ~/.cargo/bin/nimo build/
tar --zstd -cf build/nimo-v0.1.0-x86_64.tar.zst -C build nimo 
```

此时项目结构如下：

```txt
.
└── build
    ├── nimo
    └── nimo-v0.1.0-x86_64.tar.zst
```

## 编写 PKGBUILD

一个 AUR 仓库里最重要的部分就是构建脚本，也就是 PKGBUILD。创建一个 PKGBUILD 在根目录中。

```txt
.
├── build
│   ├── nimo
│   └── nimo-v0.1.0-x86_64.tar.zst
└── PKGBUILD
```

一个PKGBUILD的最小文件大致如下：

```shell
# Maintainer: levinion <levinnion@gmail.com>
pkgname=nimo-bin
pkgver=0.1.0
pkgrel=2
pkgdesc='a Rust CLI tool to fetch files or directories from GitHub with a single command'
url='https://github.com/levinion/nimo'
source_x86_64=("https://github.com/levinion/nimo/releases/download/v0.1.0/nimo-v0.1.0-x86_64.tar.zst")
arch=('x86_64')
license=('MIT')
depends=('git' 'pacman')
sha256sums_x86_64=('1a2a48db7286f9f06bfb571b7bdcd7701680fd152769042809353033aa45b1c2')

package() {
  cd "$srcdir/"
  install -Dm755 nimo "${pkgdir}/usr/bin/nimo"
}
```

- Maintainer 顾名思义是包的维护者，有时还需要加上贡献者
- pkgname 即包的名称，注意不能与 aur 中已有的包名重复
- pkgver 即包内项目/可执行文件的版本
- pkgrel 即当前 PKGBUILD 的版本，如果在上次发布后 pkgver 没变，但优化了 PKGBUILD，则 pkgrel 需要+1；当 pkgver 变化，则 pkgrel 置 1
- pkgdesc 为包的描述，尽可能言简意赅地表达出包的用处即可
- url 为项目代码的原地址
- source 为提取构建文件的路径，如果和平台相关，则需要在后面额外添加 arch
- arch 即支持构建的平台，如果无要求，写 any 即可
- licence 即项目的 License
- depends 即项目依赖，如果未安装，则会事先安装相关依赖
- sha256sums 即校验和，可使用 `makepkg --geninteg` 命令自动计算校验和，然后复制到文件中即可

主要构建流程中，只有 package 函数是必要的，其他还有 prepare、pkgver、build、check 等，在这里我们用不到，就不做示范。

package 函数的作用也就是将项目中的文件或是构建产物放到本地。这里的 `$srcdir` 即压缩包解压后的构建目录，`pkgdir` 则是一个 fakeroot 环境，指示本地目录。在 package 中我们常用 install 命令，它提供了一个简单的方式，将文件放到某个位置，同时赋予相应的权限。

```shell
install -Dm755 nimo "${pkgdir}/usr/bin/nimo"
```

- -D 标志表示自动创建目录。如果文件所在的目录不存在，则自动创建
- -m 标志指示设置文件权限，一般只读文件使用 644，可执行文件使用 755

### 检查和尝试构建

我们可以使用 namcap 命令检查 PKGBUILD 文件，并对 PKGBUILD 做进一步优化。

```shell
namcap PKGBUILD
```

然后运行如下命令以尝试在本地构建：

```shell
makepkg -s
```

调试没问题就可以发布了。

## 发布

1. 首先需要注册一个 aur 账户：[https://aur.archlinux.org/register/](https://aur.archlinux.org/register/)
2. 在注册过程中，会要求我们添加一个公钥，使用 ssh-keygen 生成，然后将公钥（. pub）填入表单中：

```shell
ssh-keygen -f ~/.ssh/aur
```

3. 然后修改 `~/.ssh/config` ：

```txt
Host aur.archlinux.org
  IdentityFile ~/.ssh/aur
  User <User Name>
```

4. 然后就可以拉取项目了，让我们先clone一下。

```shell
  git -c init.defaultBranch=master clone ssh://aur@aur.archlinux.org/nimo-bin.git
```

此处注意替换为你自己的包名，如果不存在则会自动创建一个。另外值得注意的一点是，一定需要是 master 分支。

这步操作在本地创建了一个 `nimo-bin` 目录。

5. 最后让我们将 PKGBUILD 拷贝进去。

```shell
cp PKGBUILD nimo-bin/
```

提交时除了 PKGBUILD 之外，还需要一个 `.SRCINFO` 文件，这可以用 `makepkg --printsrcinfo` 生成。

```shell
makepkg --printsrcinfo > nimo-bin/.SRCINFO
```

`.SRCINFO` 是纯文本文件，它保存一些 PKGBUILD 中的标准元数据，以方便工具解析。其格式如下：

```txt
pkgbase = nimo-bin
	pkgdesc = a Rust CLI tool to fetch files or directories from GitHub with a single command
	pkgver = 0.1.0
	pkgrel = 2
	url = https://github.com/levinion/nimo
	arch = x86_64
	license = MIT
	depends = git
	depends = pacman
	source_x86_64 = https://github.com/levinion/nimo/releases/download/v0.1.0/nimo-v0.1.0-x86_64.tar.zst
	sha256sums_x86_64 = 1a2a48db7286f9f06bfb571b7bdcd7701680fd152769042809353033aa45b1c2

pkgname = nimo-bin
```

`.SRCINFO` 在每次修改 PKGBUILD 之后均需重新生成。

6. 然后按照 git 的一般流程提交即可：

```shell
git add .
git commit -m "<Some comments>"
git push
```

此时项目目录结构如下：

```txt
.
├── build
│   ├── nimo
│   └── nimo-v0.1.0-x86_64.tar.zst
├── justfile
├── nimo-bin
│   └── PKGBUILD
└── PKGBUILD
```




