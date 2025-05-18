---
title: SDF实现圆角矩形
created: 2025-03-27 20:25:59
---
## shader

对于 vertex shader，没有任何特殊点：

```cpp
#version 330 core
layout(location = 0) in vec2 position;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
}
```

对于 fragment shader：

```cpp
#version 330 core
uniform vec2 size;
uniform float radius;
uniform vec4 color;
uniform vec2 position;

float roundedBoxSDF(vec2 p, vec2 b, float r) {
    return length(max(abs(p) - b + r, 0.0)) - r;
}
void main() {
    vec2 center = vec2(position.x + size.x / 2.0, position.y - size.y / 2.0);
    float distance = roundedBoxSDF(gl_FragCoord.xy - center, size / 2.0, radius * 100.0);
    if (distance > 0.0f) {
        discard;
    }
    gl_FragColor = color;
}
```

## SDF

上面 shader 中最重要的自然是 `roundedBoxSDF函数`：

```cpp
float roundedBoxSDF(vec2 p, vec2 b, float r) {
    return length(max(abs(p) - b + r, 0.0)) - r;
}
```

SDF 即符号距离函数，表示一个点到图形的最近距离，且带符号：正数表示点在图形外，负数反之。因此我们可以利用 SDF 函数简单获取到圆角矩形边界，并且只渲染边界内的图形，即：

```cpp
if (distance > 0.0f) {
    discard;
}
```

对于圆角矩形的 SDF，有三个参数 `p`,`b` 和 `r`，分别表示：

- 点到矩形中心的矢量，即 `gl_FragCoord.xy - center`
- 矩形的一个顶点到矩形中心的矢量（即 `[width / 2, height / 2]`）
- 圆角半径

## 消除锯齿

其中 p 是当前片元相对矩形中心的坐标，b 为二分之一矩形尺寸，radius 为圆角尺寸。

这样实现的圆角矩形在放大后会有锯齿，因此需要使用 mix 来减少锯齿。

```cpp
void main() {
    vec2 center = vec2(position.x + size.x / 2.0, position.y - size.y / 2.0);
    float distance = roundedBoxSDF(gl_FragCoord.xy - center, size / 2.0, radius * 100.0);
    float alpha = (1.0 - smoothstep(0.0f, 2.0f, distance)) * color.w;
    vec4 mixed_color = vec4(color.xyz, alpha);
    gl_FragColor = mix(mixed_color, color, alpha / color.w);
}
```
