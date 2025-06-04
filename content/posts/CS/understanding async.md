---
title: understanding async
created: 2025-06-04 00:45:41
---

异步是个很容易混淆的概念，主要是比较抽象，需要从原理出发才能更好地理解。

对于`cook`和`watchTV`，这是可以同时做，且能够打乱顺序的两件事，因此可以使用如下异步代码表示（假设cook需要3s，sweep需要1s，1s表示现实生活中10分钟）：

```js
function SomeTime(time) {
  return new Promise(resolve => {
    setTimeout(resolve, time*1000);
  });
}

async function cook() {
  console.log("Start cooking...");
  await SomeTime(3);
  console.log("End cooking...");
}

async function watchTV() {
  console.log("Start watching TV...");
  await SomeTime(1);
  console.log("End watching TV...");
}

cook()
sweep()
```

执行结果：

```shell
Start cooking...
Start watching TV...
End watching TV...
End cooking...
```

异步首先意味着它不是同步，也就是它有时可以先执行后面的代码。在上面的例子中，虽然cook比sweep先调用，但是sweep却比cooking先结束。这种乱序执行似乎和多线程相似，但异步却有可能是单线程的（比如上面的代码）。也就是说，异步对应的概念是同步，而和单/多线程没有关系。

更深入一层，让我们写出上面代码执行的实际顺序：

```shell
1. cook被调用
2. console.log("Start cooking...");
3. SomeTime(3) -> cook的计时器开始计时
4. watchTV被调用
5. console.log("Start watching TV...");
6. SomeTime(1) -> watchTV的计时器开始计时
7. 1秒，watchTV计时器到
8. console.log("End watching TV...");
9. 3秒，cook计时器到
10. console.log("End cooking...");
```

可以看到，在异步代码被调用后，会立即执行代码中的同步部分，然后在遇到第一个await时暂停，跳出函数继续执行下面的代码。当遇到完成信号时，再次返回原函数执行剩余代码。这也就是异步函数非阻塞的原因。

这样我们也就能够解释await的作用了：await标志着一个检查点，在代码执行到该点时，可以暂停并保存函数的执行状态。

对于异步代码，需要一个运行时的支持，以保存状态和调度异步任务。当异步任务创建后，会将其推送到一个任务队列，并每次调度时从任务队列中poll一个任务出来执行。poll的行为有两个结果：

- Pending：收到信号，继续执行剩余代码，直到遇到下一个await；或仍未收到信号，重新放回队列
- Finish：异步函数执行完毕

所以await也可以按其字面意思（async wait）理解为同步操作。它标志着等待一个异步操作（接收信号或取得资源）的完成，可以用来控制异步函数的执行顺序。

rust异步调度的核心是如下代码：

```rust
    pub fn try_poll(self: &Arc<Self>) {
        let mut future_slot = self.future.lock().unwrap();
        if let Some(mut future) = future_slot.take() {
            let waker = Waker::from(self.clone());
            let mut ctx = Context::from_waker(&waker);
            if future.as_mut().poll(&mut ctx).is_pending() {
                *future_slot = Some(future);
            }
        }
    }
```

总结流程也就是：

- 从队列中取出一个函数（future），恢复其状态（ctx）
- 继续执行（poll）
- 如果执行完毕，不管；否则（is_pending）就把它放到队列中（future_slot）。

rust中的协程也是基于异步做的。像是大名鼎鼎的tokio，它的实现就是通过异步和thread。tokio运行时将异步的函数交给一个线程池去执行，并且做了一些额外工作（任务窃取等）以进行任务调度。

另外，像async、await这样的关键字也意味着非抢占式调度，因为只有当一个异步函数到达await才能暂停。