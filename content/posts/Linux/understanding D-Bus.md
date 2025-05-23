---
title: understanding D-Bus
created: 2025-05-23 14:33:06
---

D-Bus的全称是Desktop Bus，即桌面总线，目的是提供一种标准的方式使得桌面进程之间能够相互通信。虽然本来服务的对象是桌面应用，但后来系统服务也开始使用D-Bus，因此`D`的意义在今天已经淡去了。

## 守护进程

让我们执行下`ps -aux | grep dbus`看一下dbus相关进程：

```shell
dbus         860  0.0  0.0   8408  3780 ?        Ss   11:08   0:00 /usr/bin/dbus-broker-launch --scope system --audit
dbus         862  0.0  0.0   5596  2828 ?        S    11:08   0:01 dbus-broker --log 4 --controller 9 --machine-id b3603f4018b5457a912421051311377e --max-bytes 536870912 --max-fds 4096 --max-matches 131072 --audit
maruka      1127  0.0  0.0   7984  3624 ?        Ss   11:08   0:00 /usr/bin/dbus-broker-launch --scope user
maruka      1128  0.0  0.0   4724  2252 ?        S    11:08   0:00 dbus-broker --log 4 --controller 10 --machine-id b3603f4018b5457a912421051311377e --max-bytes 100000000000000 --max-fds 25000000000000 --max-matches 5000000000
maruka      1411  0.0  0.0   7984  3564 ?        S    11:08   0:00 /usr/bin/dbus-broker-launch --config-file=/usr/share/defaults/at-spi2/accessibility.conf --scope user
maruka      1412  0.0  0.0   4132  2276 ?        S    11:08   0:00 dbus-broker --log 4 --controller 9 --machine-id b3603f4018b5457a912421051311377e --max-bytes 100000000000000 --max-fds 6400000 --max-matches 5000000000
```

可以看到总共有三条`dbus-broker-launch`命令，并且运行了三个`dbus-broker`守护进程。

先来看一下`dbus-proker`是什么。根据[dbus-broker](https://wiki.archlinux.org/title/D-Bus#dbus-broker)，有如下一段话：

> dbus-broker目前是 Arch 的默认实现。它是参考实现的直接替代品，旨在“提供高性能和可靠性，同时保持与 D-Bus 参考实现的兼容性”。

那么什么是参考实现？参考实现也就是freedesktop.org提供的[libdbus C API](https://dbus.freedesktop.org/doc/api/html/index.html)，它是基于D-Bus协议的简单实现。

因此，D-Bus可以说是由以下部分组成：

- D-Bus协议：进程如何连接到dbus、如何通信
- libdbus（或其他实现）：实现了D-Bus协议，使得进程不必关系细节
- dbus daemon（守护进程）：D-Bus实现的实例

一般来说，有两个主要的dbus守护进程，分别由以下两条命令开启：

```shell
/usr/bin/dbus-broker-launch --scope system --audit
/usr/bin/dbus-broker-launch --scope user
```

一个是系统范围的守护进程，一个是用户守护进程。用户守护进程很好理解，也就是负责用户空间应用的相互通信。系统守护进程为一些系统服务程序提供服务（如打印机设备的连接）。

如果你足够仔细，还能在上面看到第三个被启用的守护进程：

```shell
/usr/bin/dbus-broker-launch --config-file=/usr/share/defaults/at-spi2/accessibility.conf --scope user
```

它是由at-spi2（Assistive Technology Service Provider Interface）启动的。这是一个桌面辅助功能的接口。它并不使用已有的用户D-Bus，而选择去创建一个新的实例（不知道为什么）。

## 如何使用

下面我们看一下使用dbus的流程。下面以[dunst](https://github.com/dunst-project/dunst)（一个桌面通知程序）为例。以下这个简单的python脚本发送了一条通知，这由dunst处理后，最终显示在屏幕上。

```python
import dbus

bus = dbus.SessionBus()
object = bus.get_object(
    bus_name="org.freedesktop.Notifications",
    object_path="/org/freedesktop/Notifications",
)
interface = dbus.Interface(object, dbus_interface="org.freedesktop.Notifications")
notify = interface.get_dbus_method(member="Notify")
notify(
    "my-app",
    0,
    "dialog-information",
    "通知标题",
    "这是通知的内容。",
    [],
    {"urgency": dbus.Byte(1)},
    5000,
)
```

看不懂？没关系，继续往下看。

## dbus的一些概念

### Connection/Session

首先，我们有dbus实例（或者叫做守护进程）。

用户进程可以使用套接字（或是语言提供的绑定）连接到守护进程，这条连接就被称为Connection（连接）。有些地方也将单次连接称为Session（会话）。

```python
bus = dbus.SessionBus()
```

在python中，通过以上方法，我们的进程就连接到了用户的dbus总线上，并开始会话。

```python
bus = dbus.SystemBus()
```

使用以上方法就可以接入系统总线，两者在底层只是套接字路径的区别。

### Object

连接到D-Bus的进程可以将自己注册为一个服务，其中有Object，也被称为对象。对象也就是接口（以及方法）的集合，可以简单理解为C/C++中的类。我们可以通过名称（Name）和路径（Path）找到对应的Object。

```python
object = bus.get_object(
    bus_name="org.freedesktop.Notifications",
    object_path="/org/freedesktop/Notifications",
)
```

名称是一个唯一的字符串。它表示着一个唯一的服务。它可以有两种形式，要么是使用`.`分割的字符串列表（由服务自行注册），要么是以`:`开头的数字（由D-Bus分配）：

- org.freedesktop.Notifications
- :1.302

路径用于标识服务内部的具体对象。它的形式类似文件系统路径，如：`/org/freedesktop/Notifications`

可以使用以下命令列出所有的dbus服务名称：

```shell
dbus-send --session --dest=org.freedesktop.DBus \
  --type=method_call --print-reply \
  /org/freedesktop/DBus \
  org.freedesktop.DBus.ListNames
```

### interface和method

interface也被称为接口，是一系列方法的集合。一个对象可能包含多个interface，有种类似命名空间的味道。

method或member，也就是具体执行的函数，它接受若干参数，并且最终执行指定的操作。

使用以下命令可以获取Object下的interface和method：

```shell
dbus-send --session --dest=org.freedesktop.Notifications \
  --type=method_call --print-reply \
  /org/freedesktop/Notifications \
  org.freedesktop.DBus.Introspectable.Introspect
```

然后可以得到一个XML格式的方法和参数表。由于太长，下面只截取了我们需要的接口：

```shell
<!-- GDBus 2.84.1 -->
<node>
  ...
  <interface name="org.freedesktop.Notifications">
    <method name="GetCapabilities">
      <arg type="as" name="capabilities" direction="out">
      </arg>
    </method>
    <method name="Notify">
      <arg type="s" name="app_name" direction="in">
      </arg>
      <arg type="u" name="replaces_id" direction="in">
      </arg>
      <arg type="s" name="app_icon" direction="in">
      </arg>
      <arg type="s" name="summary" direction="in">
      </arg>
      <arg type="s" name="body" direction="in">
      </arg>
      <arg type="as" name="actions" direction="in">
      </arg>
      <arg type="a{sv}" name="hints" direction="in">
      </arg>
      <arg type="i" name="expire_timeout" direction="in">
      </arg>
      <arg type="u" name="id" direction="out">
      </arg>
    </method>
    <method name="CloseNotification">
      <arg type="u" name="id" direction="in">
      </arg>
    </method>
    <method name="GetServerInformation">
      <arg type="s" name="name" direction="out">
      </arg>
      <arg type="s" name="vendor" direction="out">
      </arg>
      <arg type="s" name="version" direction="out">
      </arg>
      <arg type="s" name="spec_version" direction="out">
      </arg>
    </method>
    <signal name="NotificationClosed">
      <arg type="u" name="id">
      </arg>
      <arg type="u" name="reason">
      </arg>
    </signal>
    <signal name="ActionInvoked">
      <arg type="u" name="id">
      </arg>
      <arg type="s" name="action_key">
      </arg>
    </signal>
  </interface>
</node>
```

如果使用`busctl`（一个systemd提供的dbus命令行工具）能够获得一个更加用户友好的格式：

```shell
busctl --user introspect org.freedesktop.Notifications /org/freedesktop/Notifications
```

这输出（同样略过了部分不需要的条目）：

```shell
NAME                                TYPE      SIGNATURE     RESULT/VALUE FLAGS
...
org.freedesktop.Notifications       interface -             -            -
.CloseNotification                  method    u             -            -
.GetCapabilities                    method    -             as           -
.GetServerInformation               method    -             ssss         -
.Notify                             method    susssasa{sv}i u            -
.ActionInvoked                      signal    us            -            -
.NotificationClosed                 signal    uu            -            -
```

可以看到参数是有类型的，常见的参数类型包括：

- s：string，字符串
- i：int，整数
- u：unsigned int，无符号整数
- as：string array，字符串数组
- {sv}：map，键为string，值为variant（可变类型，类似cpp的variant或rust的enum，也可以简单当作any）

## service

至此，dbus的主要概念都已解释完毕。上面的脚本也就能看懂了。现在，你已经知道像`dunstify`这样的工具是怎么写的了。

现在留下的问题就是，进程如何将自己注册为dbus服务。以下是一个例子：

```python
import dbus
import dbus.service
from dbus.mainloop.glib import DBusGMainLoop
from gi.repository import GLib


class EchoService(dbus.service.Object):
    def __init__(self, bus, object_path):
        dbus.service.Object.__init__(self, bus, object_path)

    @dbus.service.method(dbus_interface="top.maruka.Echo", in_signature="s")
    def echo(self, content: str):
        return content


if __name__ == "__main__":
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SessionBus()
    name = dbus.service.BusName("top.maruka.echo", bus)
    service = EchoService(bus, "/top/maruka/echo")
    mainloop = GLib.MainLoop()
    mainloop.run()
```

使用如下命令调用这个方法：

```shell
busctl --user call top.maruka.echo /top/maruka/echo top.maruka.Echo echo s "hello wrold"
```

> busctl接收的参数依次是：name、path、interface、method，以及若干个format、arg

它会返回：

```shell
s "hello wrold"
```

另外，程序（可能）会在以下目录中注册dbus-service：`/usr/share/dbus-1/services`。

如dunst就注册了如下的service：

```shell
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/bin/dunst
SystemdService=dunst.service
```

当org.freedesktop.Notifications服务被调用，若Exec中指示的进程不存在，就会去创建这个进程。如果注明了systemd service，就会去启用（start）这个服务。这也就是为什么dunst无需手动处理开机自启。另外，这也有坏处，如果你安装了dunst，但你不想用它，你会发现它还是默默地发出了一条通知，这时候你就知道是D-Bus Service搞的鬼了。

好了，现在你不仅会写`dunstify`，也会写`dunst`了。你会发现它不过就是libdbus加上一个GUI来显示信息。但是既然它好用，也就没必要造轮子了（或许还是会有人去选择造一个？）。

## 参考资料

[1] https://dbus.freedesktop.org/doc/dbus-python/tutorial.html

[2] https://www.freedesktop.org/wiki/Software/dbus/

[3] https://wiki.archlinux.org/title/D-Bus