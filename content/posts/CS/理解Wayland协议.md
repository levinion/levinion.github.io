---
title: 理解Wayland协议
created: 2025-09-11 00:01:32
---
## 协议

Wayland 本身是个协议。协议，也就是对等实体（我们对 Peer 的翻译）之间沟通的方式。

假设说有小明和小王两个人，他们隔着一堵墙，他们只能靠敲墙来进行沟通。他们已经事先交换了暗号：敲一下表示自己想要吃苹果，敲两下表示自己想要吃梨。这样，当小明听到小王敲了两下墙时，他就知道小王想要吃梨而不是苹果。

协议就相当于这个故事中的暗号，遵守且正确实现同一协议的双方能够没有歧义地交换和处理数据。

## libwayland

libwayland 是一个库，它是对 Wayland 协议的一个实现。它分为两个部分，client 和 server。在 server 端，也就是合成器端，libwayland 定义了一系列全局对象，接收从客户端发来的「请求」，从而对窗口进行调度。在客户端，则是绑定到合成器创建的对象，渲染帧，并将帧交给合成器。

客户端和服务端的沟通是通过套接字（socket）实现的。套接字的路径在大多数情况下由 `WAYLAND_DISPLAY` 环境变量指定。如果未设置该环境变量，部分应用程序会去找 `$XDG_RUNTIME_DIR/wayland-X`。

在合成器启动时，一般会主动设置当前的 `WAYLAND_DISPLAY` 环境变量。它的值一般是 `wayland-0`，如果启动了多个合成器，这个值会往上累计，变成 `wayland-1`、`wayland-2` 等等。

libwayland 在客户端的工作大概是：

- 根据环境变量获取套接字路径
- 打开套接字
- 发送请求
- 循环接收和处理合成器发来的事件

从上面可以看出，它所做的核心工作无非就是发送和接收信息，因此一个 wayland 客户端完全可以不使用 libwayland 而自行处理与套接字的交互逻辑。这样做的好处是能摆脱 libwayland 那糟糕的 XML 文件以及非常不灵活的回调函数。

## 格式

一个客户端请求分为请求头和请求体。请求头共 8 个字节，包括：

- 方法所在的对象的 id：4 个字节
- 所要调用的方法 opcode：2 个字节
- 消息（请求头 + 请求体）的长度：2 个字节

请求体长度没有要求，它所占的字节数可以由长度字段的值减去 8 个字节得到。

对于长度可变类型如字符串，则采用字符串长度 + 字符串的方式进行发送。另外，它需要按照 4 字节对齐，不足的地方补 0。

下面让我们来分析一个定义了协议的 XML 文件。它可以在 `cat /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml` 中找到。借助 `wayland-scanner` 可以从这个 XML 文件生成 C 胶水代码，此处就不讲了。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<protocol name="xdg_shell">
  <interface name="xdg_wm_base" version="7">
    ...
  </interface>
  <interface name="xdg_positioner" version="7">
    ...
  </interface>
  <interface name="xdg_toplevel" version="7">
    ...
  </interface>
</protocol>
```

XML 的最外层定义了该协议的名称为 `xdg_shell`。这是用来创建各种角色窗口（Toplevel、Popup）的一个基础协议。一个协议中会包含一到多个 interface。interface 也就是接口，或命名空间，它里面定义了多个方法。

```xml

<interface name="xdg_toplevel" version="7">
  ...
  <request name="set_title">
    <arg name="title" type="string"/>
  </request>
  ...
</interface>
```

如 `xdg_toplevel` 接口中的 `set_title` 方法，它需要接收一个 string 类型的参数。

假设我们有一个向套接字发送消息的工具函数：

```cpp
template<typename... Args>
void send_msg(const uint32_t id, const uint16_t opcode, Args... args);
```

我们已经提前获取到了 `toplevel` 对象，它的 id 是一个 u32 类型数据，让我们叫它 `toplevel_id`。

于是，我们可以这样发送请求：

```cpp
send_msg(toplevel_id, 2, "hello-world")
```

这里 opcode 为 2，因为我们调用的是 `xdg_toplevel` 这个 interface 下的第三个方法。

对于合成器事件，和上面所说的大体相同，不同之处在于字段名为 event 而不是 request。另外，一个 interface 下的 request 和 event 的 opcode 独立。
