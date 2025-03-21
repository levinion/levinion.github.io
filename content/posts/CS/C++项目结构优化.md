---
title: C++项目结构优化
created: 2025-03-09 17:19:13
---

## 前言

之前在[C++项目结构及交叉编译](https://blog.maruka.top/posts/CS/C++%E9%A1%B9%E7%9B%AE%E7%BB%93%E6%9E%84%E5%8F%8A%E4%BA%A4%E5%8F%89%E7%BC%96%E8%AF%91/)中也有介绍C++的项目结构，本次基于实际工程化做出一些改进，更加适合库的开发流程。

## 结构

```txt
.
├── assets
│   └── shader
├── build
│   ├── cmake_install.cmake
│   ├── CMakeCache.txt
│   ├── CMakeDoxyfile.in
│   ├── CMakeDoxygenDefaults.cmake
│   ├── CMakeFiles
│   ├── compile_commands.json
│   ├── libhierro.a
│   ├── Makefile
│   └── third_party
├── CMakeLists.txt
├── include
│   └── hierro
├── justfile
├── LICENSE
├── src
│   ├── app.cpp
│   ├── color.cpp
│   ├── component
│   └── err.cpp
├── tests
│   ├── build
│   ├── CMakeLists.txt
│   ├── justfile
│   └── src
├── third_party
│   ├── glad
│   └── glfw-3.4
└── toolchain.cmake
```

对于最外层：

```txt
.
├── assets
├── build
├── CMakeLists.txt
├── include
├── justfile
├── LICENSE
├── src
├── tests
├── third_party
└── toolchain.cmake
```

主要改进如下：

- 新增了`assets`用来存放外部资源，如图片、视频或shader文件。

```txt
.
└── shader
    ├── fragment.glsl
    └── vertex.glsl
```

- 新增了`tests`用来存放用例或示例，或者新增一个`examples`以单独存放示例。

```txt
.
├── build
├── CMakeLists.txt
├── justfile
└── src
```

一个示例程序结构应当符合本文所介绍的规范，但进行简化。

- 修改了`src`目录结构，原本由于项目代码较少采用扁平化结构，在代码量上升后采用树形结构以优化逻辑。

```txt
.
├── app.cpp
├── color.cpp
├── component
│   └── block.cpp
└── err.cpp
```

- 对于`include`目录，同理采用树形结构，并且当前项目头文件应当存放在以当前项目名称命名的文件夹中。

```txt
.
└── hierro
    ├── app.h
    ├── color.h
    ├── component
    │   ├── block.h
    │   └── component.h
    ├── err.h
    └── shader
        ├── fragment.h
        └── vertex.h
```

使用这种方式，用户可以以`#include "hierro/app.h"`的方式引用头文件，从而避免命名冲突。

## CMakeLists

```txt
# project
set(name "hierro")
cmake_minimum_required(VERSION 3.10)
project(${name} CXX)

# clang setting
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# set(CMAKE_CXX_COMPILER "/usr/bin/clang++" CACHE STRING "C++ compiler" FORCE)
set(CMAKE_CXX_STANDARD 26)

# src
file(GLOB_RECURSE SRC src/*.cpp)
add_library(${name} ${SRC})
target_include_directories(${name} PUBLIC include/)

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

- 使用`target_include_directories(${name} PUBLIC include/)`取代`include_directories(include/)`，以更方便用户使用`target_link_libraries`引用库项目头文件。
- 使用`file(GLOB_RECURSE SRC src/*.cpp)`取代`file(GLOB SRC src/*.cpp)`，以包括树形结构下的全部`cpp`文件
- 使用`set(CMAKE_CXX_STANDARD 26)`显式指定当前使用的C++版本
- 使用`set(CMAKE_CXX_COMPILER "/usr/bin/clang++" CACHE STRING "C++ compiler" FORCE)`显式指定当前所使用的编译器（可选，指定编译器有助于使用特定编译器支持的特性，但不便于在不同机器上编译）

## 构建脚本

```justfile
name := `cat build/CMakeCache.txt | grep CMAKE_PROJECT_NAME | awk -F '=' '{print $2}'`

init:
  cmake -B build

init_windows:
  cmake -B build -DCMAKE_TOOLCHAIN_FILE=./toolchain.cmake

build:
  cmake --build build

embed:
  xxd -n _vertex_shader_code -i ./assets/shader/vertex.glsl | sed "s/}/,\'\\\0\'}/" > ./include/shader/vertex.h
  xxd -n _fragment_shader_code -i ./assets/shader/fragment.glsl | sed "s/}/,\'\\\0\'}/" > ./include/shader/fragment.h
  clang-format -i ./include/shader/*

run:
  just build
  ./build/{{name}}

run_windows:
  just build
  ./build/{{name}}.exe

clean:
  rm -rf build
```

- 使用justfile变量，以减少`Shebang`配方的使用
- 新增`embed`，支持快速文本嵌入，具体见[C++文本嵌入二进制最佳实践](https://blog.maruka.top/posts/CS/C++%E6%96%87%E6%9C%AC%E5%B5%8C%E5%85%A5%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%9C%80%E4%BD%B3%E5%AE%9E%E8%B7%B5/)
