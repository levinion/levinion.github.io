---
title: libmpv实现推帧
created: 2025-05-18 00:11:56
---
## 什么是推帧

libmpv 是一个嵌入的 mpv 播放器，可以直接将 mpv 播放器渲染到窗口或 fbo/texture 上。

推帧也就意味着，每当我们向播放器传入一个图片/纹理时，播放器播放一帧。这在需要实时更新播放器显示的图像时很有用。

## 为何要利用 libmpv 推帧

推帧，也就是传入和显示一个纹理，一般可以直接通过 OpenGL 实现。利用 libmpv 主要是利用其一些副作用：比如图像后处理。它可以通过 mpv user shader 对图像进行一些后处理（锐化、超分等）。

## 自定义流

libmpv 默认不支持推帧，因此需要利用自定义流（[streamcb](https://github.com/mpv-player/mpv-examples/blob/master/libmpv/streamcb/simple-streamcb.c)）手动实现推帧方法。

推帧一般有以下方法：

```cpp
Video* init(VideoSettings);
void update(unsigned char* data, int size);
void render();
void terminate();
```

### 初始化

首先是 init，在此处进行播放器的初始化。

在此之前，先创建一些要用到的 hook 和工具函数：

```cpp
// 读取流的大小，如果是视频流，那么就是视频解码后的大小，此处由于是实时推帧，因此返回不支持长度读取
static int64_t size_fn(void* cookie) {
  return MPV_ERROR_UNSUPPORTED;
}

// 实际读取函数
static int64_t read_fn(void* cookie, char* buf, uint64_t nbytes) {
  auto* fs = static_cast<FrameStream*>(cookie);
  Frame frame;
  while (fs->stream.try_dequeue(frame) == false) {
    if (fs->should_close)
      return 0;
    fs->update_flag.wait(false);
    fs->update_flag.store(false);
  }
  uint64_t to_copy = std::min<uint64_t>(frame.size, nbytes);
  memcpy(buf, frame.data, to_copy);
  return to_copy;
}

// 不支持快进、后退，所以返回不支持
static int64_t seek_fn(void* cookie, int64_t offset) {
  return MPV_ERROR_UNSUPPORTED;
}

// 在此处进行一些资源的清理，由于没有需要清理的资源，跳过
static void close_fn(void* cookie) {}

// 打开流时执行的操作，即一些初始化。
static int open_fn(void* user_data, char* uri, mpv_stream_cb_info* info) {
  auto fs = static_cast<FrameStream*>(user_data);
  info->cookie = fs;
  info->size_fn = size_fn;
  info->read_fn = read_fn;
  info->seek_fn = seek_fn;
  info->close_fn = close_fn;
  return 0;
}

// 获取OpenGL上下文，用于后续渲染
static void* get_proc_address_mpv(void* fn_ctx, const char* name) {
  return (void*)SDL_GL_GetProcAddress(name);
}
```

以上比较重要的有 `open_fn` 和 `read_fn`。

```cpp
static int open_fn(void* user_data, char* uri, mpv_stream_cb_info* info) {
  auto fs = static_cast<FrameStream*>(user_data);
  info->cookie = fs;
  info->size_fn = size_fn;
  info->read_fn = read_fn;
  info->seek_fn = seek_fn;
  info->close_fn = close_fn;
  return 0;
}
```

在 `open_fn` 中传入需要用到的钩子，另外可以将一个指针传递给 cookie，用来作为主线程和 libmpv 线程之间交流的工具（即共享内存）。这里我们传入了一个 FrameStream 指针，它的定义如下：

```cpp
class Frame {
public:
  unsigned char* data;
  int size;
};

class FrameStream {
public:
  moodycamel::ConcurrentQueue<Frame> stream;
  std::atomic<bool> update_flag;
  std::atomic<bool> should_close;
};
```

FrameStream 中包含一个线程安全的无锁队列，因此可以向它推帧或读取。

```cpp
static int64_t read_fn(void* cookie, char* buf, uint64_t nbytes) {
  auto* fs = static_cast<FrameStream*>(cookie);
  Frame frame;
  while (fs->stream.try_dequeue(frame) == false) {
    if (fs->should_close)
      return 0;
    fs->update_flag.wait(false);
    fs->update_flag.store(false);
  }
  uint64_t to_copy = std::min<uint64_t>(frame.size, nbytes);
  memcpy(buf, frame.data, to_copy);
  return to_copy;
}
```

在 `read_fn` 中实现 libmpv 读取逻辑，实际流程大概如下所述：

1. 向队列中推了一帧，唤醒读取线程
2. 读取线程被唤醒，从队列获取输入的帧
3. 将帧中的数据拷贝到 libmpv 的缓冲区当中
4. 返回拷贝数据的长度
5. libmpv 执行一系列后处理，并将帧渲染到 fbo/屏幕上

之后就可以进行实际初始化工作了：

```cpp
Video* Video::init(VideoSettings settings) {

// ... 一些其他组件的初始化

  // 创建libmpv实例
  this->mpv = mpv_create();
  // 设置libmpv的一些属性
  mpv_set_option_string(mpv, "vo", "libmpv");
  mpv_set_option_string(mpv, "untimed", "yes");
  // 重要：设置输入格式为rawvideo
  mpv_set_option_string(mpv, "demuxer", "rawvideo");
  // 输入纹理的尺寸
  mpv_set_option_string(
    mpv,
    "demuxer-rawvideo-w",
    std::to_string((int)frame_size.width).c_str()
  );
  mpv_set_option_string(
    mpv,
    "demuxer-rawvideo-h",
    std::to_string((int)frame_size.height).c_str()
  );
  // 输入纹理的格式
  mpv_set_option_string(
    mpv,
    "demuxer-rawvideo-mp-format",
    settings.format.c_str()
  );
  // 帧率
  mpv_set_option_string(mpv, "demuxer-rawvideo-fps", "60");
  // 不提前加载
  mpv_set_option_string(mpv, "demuxer-readahead-secs", "0");
  // 初始化libmpv
  if (mpv_initialize(mpv) < 0) {
    spdlog::error("mpv initialize failed");
  }
  // 日志等级
  mpv_request_log_messages(mpv, "warn");

  // 重要：注册一个自定义流
  mpv_stream_cb_add_ro(mpv, "kaleido", &this->frame_stream, open_fn);
  // OpenGL上下文
  auto op = (mpv_opengl_init_params) {
    .get_proc_address = get_proc_address_mpv,
  };
  // 生成和绑定fbo
  glGenFramebuffers(1, &fbo);
  glBindFramebuffer(GL_FRAMEBUFFER, fbo);
  auto texture =
    Texture(NULL, frame_size.width, frame_size.height, settings.gl_format);
  glFramebufferTexture2D(
    GL_FRAMEBUFFER,
    GL_COLOR_ATTACHMENT0,
    GL_TEXTURE_2D,
    texture.id(),
    0
  );

  if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
    spdlog::error("fbo failed created");
  }
  // 解绑当前fbo，从而防止错误的渲染
  glBindFramebuffer(GL_FRAMEBUFFER, 0);

  // 设置播放器尺寸
  mpfbo.w = frame_size.width;
  mpfbo.h = frame_size.height;
  // 设置fbo
  mpfbo.fbo = this->fbo;
  // 目标纹理
  this->texture = texture;
  // block是一个组件，负责将纹理渲染到屏幕
  block->set_texture(this->texture);
  // 传入参数
  std::vector<mpv_render_param> params = {
    { MPV_RENDER_PARAM_API_TYPE, (void*)MPV_RENDER_API_TYPE_OPENGL },
    { MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &op },
    // { MPV_RENDER_PARAM_ADVANCED_CONTROL, &advanced_control },
    { MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo },
    { MPV_RENDER_PARAM_INVALID, NULL },
  };
  // 创建渲染上下文
  mpv_render_context_create(&mpv_gl, mpv, params.data());
  // 保存渲染参数，以供后续使用
  this->params = params;
  // 打开并执行自定义流
  const char* cmd[] = { "loadfile", "kaleido://fake", NULL };
  mpv_command(mpv, cmd);

  return this;
}
```

### 更新

```cpp
void Video::update(unsigned char* data, int size) {
  frame_stream.stream.enqueue(Frame { data, size });
  frame_stream.update_flag.store(true);
  frame_stream.update_flag.notify_one();

  // handle event
  mpv_event* event = mpv_wait_event(mpv, 0);
  if (event->event_id == MPV_EVENT_LOG_MESSAGE) {
    mpv_event_log_message* msg = (mpv_event_log_message*)event->data;
    spdlog::warn("[{}] {}: {}", msg->prefix, msg->level, msg->text);
  }
}
```

更新的逻辑很简单，向队列中推流，并且唤醒读取线程。顺便打印 libmpv 日志。

### 渲染

```cpp
void Video::render() {
  auto flag = mpv_render_context_update(mpv_gl);
  if (flag & MPV_RENDER_UPDATE_FRAME) {
    mpfbo.w = frame_size.width;
    mpfbo.h = frame_size.height;
    glViewport(0, 0, frame_size.width, frame_size.height);
    mpv_render_context_render(mpv_gl, params.data());
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, window_size.width, window_size.height);
  }
}
```

渲染比较关键的是两个函数：`mpv_render_context_update` 以及 `mpv_render_context_render`。`mpv_render_context_update` 通知内容更新，`mpv_render_context_render` 负责绘制。

此外，需要在执行 `mpv_render_context_render` 函数前将视口大小设置为传入纹理的大小，否则使得渲染结果不正确。

### 销毁

```cpp
void Video::terminate() {
  this->frame_stream.should_close = true;
  // notify to prevent dead lock
  frame_stream.update_flag.store(true);
  frame_stream.update_flag.notify_one();
  mpv_render_context_free(mpv_gl);
  mpv_terminate_destroy(mpv);
}
```

首先通知 libmpv，使其从等待读取状态中退出，然后依次释放渲染器和 libmpv handle。如果不在释放 handle 前释放 renderer 的话，可能导致 core dump。

## 运行时命令

还可以在运行时向 libmpv 发送一些指令，以控制 libmpv 的渲染流程（启用/停用自定义 shader、显示文本等都可以通过这种方式做到）：

```cpp
void Video::send_command(std::vector<std::string> cmd) {
  // vector<string> to const char*
  std::vector<const char*> cstrings;
  for (auto& s : cmd) {
    auto data = s.c_str();
    cstrings.push_back(data);
  };
  cstrings.push_back(0);
  // send command
  mpv_command(mpv, cstrings.data());
}
```
