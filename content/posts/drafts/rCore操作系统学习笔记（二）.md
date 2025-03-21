---
title: rCore操作系统学习笔记（二）
created: 2023-05-02 17:34:00
---
添加交叉编译的架构类型
```sh
rustup target add riscv64gc-unknown-none-elf
```

交叉编译 trick
```txt
# os/.cargo/config
[build]
target="riscv64gc-unknown-none-efl"
```

运行 cargo run 报错
```sh
error[E0463]: can't find crate for `std`
  |
  = note: the `riscv64gc-unknown-none-elf` target may not support the standard library
  = note: `std` is required by `os` because it does not declare `#![no_std]`
  = help: consider building the standard library from source with `cargo build -Zbuild-std`

error: cannot find macro `println` in this scope
 --> src/main.rs:2:5
  |
2 |     println!("Hello, world!");
  |     ^^^^^^^

error: `#[panic_handler]` function required, but not found

For more information about this error, try `rustc --explain E0463`.
error: could not compile `os` (bin "os") due to 3 previous errors
```

为 main 函数添加 `#![std]`，禁用 std 库而使用 core 核心库
```rust
#![no_std]
fn main() {
    println!("Hello, world!");
}
```

报错
```rust
error: cannot find macro `println` in this scope
 --> src/main.rs:3:5
  |
3 |     println!("Hello, world!");
  |     ^^^^^^^

error: `#[panic_handler]` function required, but not found

error: could not compile `os` (bin "os") due to 2 previous errors
```

实现 panic

```rust

```
