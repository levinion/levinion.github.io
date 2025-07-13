---
title: wayland如何处理事件
created: 2025-07-13 17:25:23
---
wayland采用事件回调机制。

与X在服务端渲染不同，wayland中客户端负责渲染操作，而wayland服务器只负责将客户端渲染的内容同步到屏幕上，也就是合成。所以wayland服务器也可以叫做合成器/混成器，或compositor。

wayland要使客户端和服务端能够沟通，就需要协商好信息的格式，这也就是协议。协议包括了函数名和参数名称以及格式。一个wayland协议是一个xml文件，它可以通过扫描器（wayland-scanner）转成`.h`格式的C头文件，从而被C/C++调用。

协议中，将服务端发往客户端的通知叫做event，而把客户端发往服务端的消息叫做request。

为了处理客户端请求，服务端需要运行一个event_loop，而在这个循环中的主要工作就是处理事件回调。

事件回调处理中有几个主要概念：

- wl_listener：事件的监听器。
- wl_signal：信号，通常由协议提供
- callback：也就是回调函数

通常先将callback传递进wl_listener的notify中，然后用`wl_add_signal`函数将signal绑定到listener。表明该listener将监听请求，并在请求发生时执行回调函数。

回调函数的声明大致如下：

```cpp
void callback(wl_listener* listener, void* data);
```

在编写一个callback时，需要获取与这个事件有关的一些对象，并对这些对象执行操作。我们可以使用一个神奇的宏`wl_container_of(listener, sample, member)`来获取到存放着这个listener的结构体/类的实例指针。宏的定义如下：

```cpp
#define wl_container_of(ptr, sample, member)				\
	(WL_TYPEOF(sample))((char *)(ptr) -				\
			     offsetof(WL_TYPEOF(*sample), member))
```

虽然很神奇但也很简单，就是传入的listener地址减去listener在对象中的偏移，从而获取到这个对象的地址。

`data`也就是客户端的传参，根据事件不同，一般可以将其强转成协议头文件提供的某个结构体指针。

在实际代码中，使用这个宏需要将事件的listener和所有事件需要用到的成员包裹在同一个结构体当中，因此一旦事件一多，就会导致代码冗长，样板代码多，且很难抽象。

为了应对这种情况，可以使用一个对象，可以取名叫做EventManager（或其他的什么东西），然后创建一些方法：

```cpp
class EventManager {
public:

  static std::unique_ptr<EventManager> init();

  template<typename F>
  void register_signal(wl_signal* signal, F f, void* data) {
    auto handler = std::make_unique<EventHandler>();
    auto listener = wl_listener {};

    handler->listener = listener;
    handler->listener.notify = f;
    wl_signal_add(signal, &handler->listener);

    this->handlers[&handler->listener] = std::move(handler);
  }

  template<typename T>
  T get(wl_listener* listener) {
    return static_cast<T>(this->handlers[listener]);
  }

private:
  std::unordered_map<wl_listener*, std::unique_ptr<EventHandler>> handlers;
};

```

其中EventHandler如下：

```cpp
class EventHandler {
public:
  wl_listener listener;
  void* data;
};

```

这样做的好处在于无需在结构体中创建很多的listener，而只需要在注册回调时指定关联的结构体即可。