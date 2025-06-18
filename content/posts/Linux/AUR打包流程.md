---
title: AUR打包流程
created: 2025-01-06 23:51:31
---
> 2025/6/18更新：新增了git包的打包流程

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

一个 PKGBUILD 的最小文件大致如下：

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
- pkgrel 即当前 PKGBUILD 的版本，如果在上次发布后 pkgver 没变，但优化了 PKGBUILD，则 pkgrel 需要 +1；当 pkgver 变化，则 pkgrel 置 1
- pkgdesc 为包的描述，尽可能言简意赅地表达出包的用处即可
- url 为项目代码的原地址
- source 为提取构建文件的路径，如果和平台相关，则需要在后面额外添加 arch
- arch 即支持构建的平台，如果无要求，写 any 即可
- licence 即项目的 License
- depends 即项目依赖，如果未安装，则会事先安装相关依赖
- sha256sums 即校验和，可使用 `makepkg --geninteg` 命令自动计算校验和，然后复制到文件中即可（或者直接填'SKIP'跳过，如果是bin包不建议跳过，除非技术上无法或很难获取到校验和）

主要构建流程中，只有 package 函数是必要的，其他还有 prepare、pkgver、build等，在这里我们用不到，就不做示范。

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

4. 然后就可以拉取项目了，让我们先 clone 一下。

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

6. 然后按照 Git 的一般流程提交即可：

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

## GIT包打包流程

在AUR上，除了bin包之外，最常见的是git包。git包一般直接从远程git仓库（如Github）拉取源码，然后在本地构建和安装。相比上面的bin包，这个PKGBUILD会更加通用。

```shell
# Maintainer: levinion <levinnion@gmail.com>
pkgname=stor
pkgver=0.1.1
pkgrel=2
pkgdesc="An alternative to GNU Stow written in rust."
url="https://github.com/levinion/stor"
arch=("any")
license=("GPLv3")
depends=('gcc-libs' 'glibc')
makedepends=("cargo" "git")
provides=("stor")
conflicts=("stor-bin")
source=(
  "$pkgname::git+https://github.com/levinion/$pkgname.git"
)
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/$pkgname"
  cargo pkgid | cut -d '#' -f2
}

build() {
  cd "$srcdir/$pkgname"
  export RUSTUP_TOOLCHAIN=stable
  export CARGO_TARGET_DIR=target
  cargo build --release --locked
}

package() {
  cd "$srcdir/$pkgname"
  install -Dm755 "target/release/$pkgname" "$pkgdir/usr/bin/$pkgname"
  install -Dm644 "LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  install -Dm644 "completions/zsh/_$pkgname" "$pkgdir/usr/share/zsh/site-functions/_$pkgname"
}
```

### 依赖

依赖分为`depends`和`makedepends`，也就是运行时依赖和构建依赖。

makedepends表明了包在构建时依赖哪些包。说人话就是通过哪些包我们能够得到最后的可执行文件。它里面所包含的项目通常在prepare和build阶段使用。例子中的stor（我写的，欢迎尝试！）是一个rust cli工具，所以它需要cargo（rust的包管理器）进行构建。另外，由于是从Github拉取代码，所以也需要依赖git。

depends也就是安装到系统中可执行文件需要哪些包才能正常运行。可以看到它动态链接了gcc和libc，因此在depends里面补上即可。

```shell
❯ ldd /usr/bin/stor
linux-vdso.so.1 (0x00007b54793f4000)
libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007b5479383000)
libm.so.6 => /usr/lib/libm.so.6 (0x00007b547928b000)
libc.so.6 => /usr/lib/libc.so.6 (0x00007b5478e10000)
/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007b54793f6000)
```

### VCS

这里的source用到了[VCS源](https://wiki.archlinux.org/title/VCS_package_guidelines#VCS_sources)。拉取一个git仓库的标准模板为`source=('project_name::git+https://project_url#branch=project_branch')`，因此对于git包可以不用显式地在prepare函数中进行clone操作，pacman会自动完成。

### 执行流

之前也提到过，PKGBUILD中常用流程函数主要包括prepare、pkgver、build、package等。

在prepare阶段，我们主要获取一些资源，如代码文件和依赖的库。对于那些在构建时从远程获取库的包管理器（如cargo）来说，可以将这一步（cargo fetch）单独拆出来放在prepare中执行，当然也可以放在build中一起执行。

在build阶段，运行构建命令获取编译结果（通常是可执行文件）。

在package阶段，将需要的东西安装到系统中。将可执行文件放到`/usr/share/bin/`，将license放到`"/usr/share/licenses/$pkgname/`下面。如果有shell补全，放到对应目录下，对于zsh则是`/usr/share/zsh/site-functions/`。

对于git包，最好写上pkgver函数。它取代了pkgver变量来动态获取当前包的版本，因此可以不必经常修改PKGBUILD。在这里，它从cargo获取crate的version：

```shell
pkgver() {
  cd "$srcdir/$pkgname"
  cargo pkgid | cut -d '#' -f2
}
```

或者更通用地，使用git标签来管理版本。[Archwiki](https://wiki.archlinux.org/title/VCS_package_guidelines#Git)上提供了一些方法，如：

```shell
pkgver() {
  cd "$pkgname"
  git describe --long --abbrev=7 | sed 's/\([^-]*-g\)/r\1/;s/-/./g'
}
```

这可以获取最新的标签所显示的版本。

另外值得注意的一点是，一个包的版本号最好使用同一种命名方法，不建议两种命名方式的混用，比如下面的两种命名方式，一个加v，一个不加v，最后的结果可能出乎意料：

```shell
❯ vercmp 0.1.0 v1.0.0
1
```

其中1表示左边比右边大，这显然是不合理的。因为这属于两种命名方式，vercmp（这是pacman所使用的比较包版本的程序）可能会认为中途改变了命名方式（无论原因如何）从而认为另一种不同的命名方式一定比前一种命名方式大（或小），而不去管数字如何。在这边，vercmp认为加v的一定比不加v的小。