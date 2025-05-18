---
title: C++项目结构及交叉编译
created: 2025-01-16 22:04:53
---
## 前言

C++ 的项目结构一直是个难点。虽然有着 vcpkg 等工具，但当前的 C++ 项目仍主要采用 cmake 进行管理，由于这种构建脚本的方式，以及现代化语言的包管理器（类似 cargo、pip/uv 或 go mod）的缺失，因此也没有一个统一的项目结构。另外，C++ 的交叉编译也无法做到开箱即用，需要另外配置。

本篇主要介绍一下我个人在项目中所认为的合理结构，以及在 WSL 下开发 Windows 应用程序的过程。

## 干净的 C++ 项目结构

下面是一个简单的 opengl 项目的项目结构。

- `build` 目录是构建目录，应当添加到项目的 `.gitignore` 当中；
- `include` 是项目头文件；
- `src` 存放项目源码；
- `third_party` 存放引用的第三方库，每个第三方库都应当包含有自己的 `CMakeLists`，从而能够被主 `CMakeLists` 引用；
- `.clang-format` 用以控制格式化风格（可选，仅针对使用 clangd 的用户）；
- `.gitignore` 规定 Git 忽略的文件/目录，至少应当包含 `build` 目录；
- `CMakeLists.txt` 是项目主要的 cmake 配置文件；
- `justfile` 是构建脚本，用以方便地执行一些编译指令；
- `toolchain` 用以帮助进行交叉编译；

```txt
.
├── build
│   ├── CMakeFiles
│   ├── third_party
│   ├── CMakeCache.txt
│   ├── Makefile
│   ├── cmake_install.cmake
│   ├── compile_commands.json
│   └── opengl-example.exe
├── include
│   ├── app.h
│   └── err.h
├── src
│   ├── app.cpp
│   ├── err.cpp
│   └── main.cpp
├── third_party
│   ├── glad
│   └── glfw-3.4
├── .clang-format
├── .gitignore
├── CMakeLists.txt
├── justfile
└── toolchain.cmake
```

对于一些较复杂的项目，需要拆分成多个库，可在根目录新建以该库为名的新的子目录，且每个库的结构应当与上面的结构一致。

## 一个干净的 CMakeLists 文件

一个干净的 `CMakeLists` 文件应当有良好的分类以及简洁的注释。

- 项目设置：合理利用变量，确保项目名称只在脚本中出现一次，从而方便后续修改；
- `clang` 设置（可选，仅针对使用 clangd 的用户）：令 cmake 输出 `compile_commands.json` 文件，使 clangd 正确运行；
- 源码编译：这里特指属于自己项目的源码，主要包括 include 中的头文件以及 src 中的 cpp 文件，将以上文件包含在构建目录中，这里提供了一种比较通用的写法；
- 静态链接 std 库：对于交叉编译，如果采用动态链接，经常会发生 std 库找不到的情况，因此推荐使用静态链接；
- 第三方库编译：对于每个第三方库，单独配置编译，建议采用库 README 中推荐的写法；对于没有 CMakeLists 的库，可在拷贝源码后为其单独编写 CMakeLists；

```cmake
# project
set(name "opengl-example")
cmake_minimum_required(VERSION 3.10)
project(${name} CXX)

# clang setting
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# src
include_directories(include)
file(GLOB SRC src/*.cpp)
add_executable(${name} ${SRC})

# link std library static
target_link_options(${name} PRIVATE -static-libgcc -static-libstdc++)

# third party
add_subdirectory(./third_party/glfw-3.4)
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
target_link_libraries(${name} glfw)

find_package(OpenGL REQUIRED)
target_link_libraries(${name} OpenGL::GL)

add_subdirectory(./third_party/glad)
target_link_libraries(${name} glad)
```

## 交叉编译

如果要进行交叉编译，首先需要准备工具链以及相对应的工具链文件。对于 Linux 编译 Windows 程序，一般使用 mingw。

对于 ArchLinux 来说，需要安装 `mingw-w64-gcc`，这会安装该程序和与之对应的头文件。

```shell
sudo pacman -S mingw-w64-gcc
```

在项目根目录创建 `toolchain.cmake` 文件，并填入以下内容。

```cmake
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(TOOLCHAIN_PREFIX x86_64-w64-mingw32)

# cross compilers to use for C, C++ and Fortran
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)
set(CMAKE_Fortran_COMPILER ${TOOLCHAIN_PREFIX}-gfortran)
set(CMAKE_RC_COMPILER ${TOOLCHAIN_PREFIX}-windres)

# target environment on the build host system
set(CMAKE_FIND_ROOT_PATH /usr/${TOOLCHAIN_PREFIX})

# modify default behavior of FIND_XXX() commands
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
```

然后指定该工具链，生成构建文件：

```shell
cmake -B build -DCMAKE_TOOLCHAIN_FILE=./toolchain.cmake
```

之后可正常开始编译：

```shell
cmake --build build
```

## 通用的构建脚本写法

对于 c++ 项目来说，有些命令会多次执行，因此一般都会配置一个构建脚本。一般使用较多的包括初始化、编译、运行、清理。这里提供一个通用的构建脚本写法(基于 justfile)：

```shell
init:
  cmake -B build

init_windows:
  cmake -B build -DCMAKE_TOOLCHAIN_FILE=./toolchain.cmake

build:
  cmake --build build

run:
  #!/usr/bin/bash
  just build
  name=$(cat build/CMakeCache.txt | grep CMAKE_PROJECT_NAME | awk -F '=' '{print $2}') 
  ./build/$name.exe

clean:
  rm -rf build
```

其中 init 开头的指令用以生成构建系统文件，仅在初始化时执行。

## 其他

一般来说，代码格式化风格全凭个人喜好，但是其中一项设置可能导致项目出错，因此建议始终保持如下设置（在 `.clang-format` 中）：

```
SortIncludes: Never
```
