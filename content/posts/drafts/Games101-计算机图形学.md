---
title: Games101-计算机图形学
created: 2023-06-10 13:48:15
---

## 计算机图形学

### 应用
- 电影、动画特效、设计（CAD）、CG（Computer Graphics）
- 可视化、虚拟现实、仿真/模拟
- 图形界面、字体...

### 挑战
真实世界的理解、计算方法、显示方法

### 内容
数学理论、着色、形体、仿真动画，不包括OpenGL、DirectX、Vulcan等（图形学api）

- 光栅化：广泛应用在实时图形学(>30fps)
- 几何（曲线和曲面）
- 光线追踪：能达到较好的效果，但较慢
- 动画/模拟

> 图形学（模型渲染图片）!=计算机视觉（图片提取信息：分析、猜测、理解、推理）

## 线性代数
坐标、平移、旋转 ==> 矩阵计算

### 向量
![](https://www.zhihu.com/equation?tex=\bbox[white]{\vec{AB}=\vec{B}-\vec{A}})

- 向量加法（三角形法则）
![](https://www.zhihu.com/equation?tex=\bbox[white]{\vec{AB}=\vec{AO}%2B\vec{OB}})

- 向量点乘（Dot）: 表示方向性
![](https://www.zhihu.com/equation?tex=\bbox[white]{\vec{a}\cdot\vec{b}=|\vec{a}||\vec{b}|\cdot\cos(\theta)})

- 投影
b在a上的投影：![](https://www.zhihu.com/equation?tex=\bbox[white]{k=|\vec{b}|\cos\theta})

- 叉乘（方向根据右手定则）：已知两个坐标系得到另一个坐标系
![](https://www.zhihu.com/equation?tex=\bbox[white]{|\vec{a}\times\vec{b}|=|\vec{a}||\vec{b}|\sin\phi})


### 矩阵
- 矩阵乘法（矩阵X矩阵、矩阵X向量）
- 结合律、分配律、无交换律
- 单位矩阵
- 逆矩阵

## 变换
变换即是对目标的每一个点进行变换，以得到整体的改变。复杂变换可由简单变换得到，和变换的顺序有关。

### 二维变换

#### 缩放变换
![](https://www.zhihu.com/equation?tex=\bbox[white]{x^{'}=sx~~or~~y^{'}=sy})

#### 反转
![](https://www.zhihu.com/equation?tex=\bbox[white]{x^{'}=-x~~or~~y^{'}=-y})

$$\begin{bmatrix}
x^{'} \\ y^{'}
\end{bmatrix}
=
\begin{bmatrix}
-1 & 0 \\ 0 & 1 
\end{bmatrix}
\begin{bmatrix}
x \\ y
\end{bmatrix}
$$

#### 切变

$$\begin{bmatrix}
x^{'} \\ y^{'}
\end{bmatrix}
=
\begin{bmatrix}
1 & a \\ 0 & 1 
\end{bmatrix}
\begin{bmatrix}
x \\ y
\end{bmatrix}
$$

#### 旋转

$$R_\theta=\begin{bmatrix}
\cos\theta & -\sin\theta\\
\sin\theta & \cos\theta 
\end{bmatrix}
$$

#### 线性变换

$$\begin{bmatrix}
x^{'}\\ y^{'}
\end{bmatrix}
=
\begin{bmatrix}
a&b\\ c&d
\end{bmatrix}
\begin{bmatrix}
x\\ y
\end{bmatrix}$$

即
$$x^{'}=ax+by$$

$$y^{'}=cx+dy$$

即
$$x^{'}=Mx$$

称为线性变换。以上均属于线性变换。

#### 平移
平移是一种特殊的二维变换，它不属于线性变换，因为：
$$
\begin{bmatrix}
x^{'}\\ y^{'}
\end{bmatrix}=
\begin{bmatrix}
a & b \\ c&d
\end{bmatrix}
\begin{bmatrix}
x \\ y
\end{bmatrix}
+
\begin{bmatrix}
t_x \\ t_y
\end{bmatrix}$$

为了解决其特殊性，引入齐次坐标。

#### 引入齐次坐标
为二维的点或向量增加一个维度，得到仿射变换的通式。

$$\begin{bmatrix}
x^{'}\\ y^{'} \\ w^{'}
\end{bmatrix}
=
\begin{bmatrix}
1&0&t_x\\ 0&1&t_y\\ 0& 0 &1
\end{bmatrix}
\begin{bmatrix}
x\\ y\\ 1
\end{bmatrix}
=\begin{bmatrix}
x+t_x \\ y+t_y\\ 1
\end{bmatrix}$$

w 为 0 或 1，以满足平移变换后的向量或点的不变性。其中 0 表示向量，1 表示点。

因此：
- 点-点=向量
- 向量+-向量=向量
- 点+-向量=点
- 点+点=2？=>点，若w!=0，w=w/w，x=x/w，其他同理

代价即是引入了一个额外的坐标，但是可省略仿射变换，只保留左上角矩阵，因此代价不高。

另外，在三维空间中，用四个参数描述一个三维齐次坐标系下的点。

#### 变换的组合性

$$R=A_1*A_2*...*S$$

复杂变换可由简单变换组合而成，其顺序相关，同时变换矩阵维数相同（3\*3）

### 三维变换
同二维变换，用四个坐标描述一个三维坐标中的点：一个四维矩阵

#### 旋转

有旋转矩阵：

$$
R_{x}(\alpha)=
\begin{bmatrix}
1&0&0&0 \\
0&\cos \alpha & -\sin \alpha &0 \\
0 &\sin \alpha &\cos \alpha &0 \\
0&0&0&1
\end{bmatrix}
$$

$$
R_{y}(\alpha)=
\begin{bmatrix}
\cos \alpha&0&\sin \alpha&0 \\
0&1 & 0 &0 \\
- \sin \alpha&0 &\cos \alpha &0 \\
0&0&0&1
\end{bmatrix}
$$

$$
R_{z}(\alpha)=
\begin{bmatrix}
\cos \alpha&-\sin \alpha&0 &0\\
\sin \alpha&\cos \alpha & 0 &0 \\
0 &0 &0&0 \\
0&0&0&1
\end{bmatrix}
$$

三维旋转可由三个独立二维旋转行为描述，用欧拉角描述，分为横滚角、俯仰角、航向角

$$R_{xyz}(\alpha,\beta,\gamma)=R_x(\alpha)R_y(\beta)R_z(\gamma)$$

> 罗德里格斯旋转公式：
> $$R = I + \sin\theta * A + (1-\cos\theta) * A^2$$
> 可计算出任意轴和任意角度的旋转变换矩阵

### MVP变换
M - Model 变换: 将物体从对象空间转换到世界空间。它包含物体的缩放、旋转和位置变换。

V - View 变换: 将世界空间转换到视图空间。它决定摄像机的位置和方向。

P - Projection 变换: 将视图空间转换到裁剪空间。它实现透视效果, 包含视锥体和视口的定义。

这三个变换的综合结果是将三维物体最终投影到二维屏幕上的效果。它们的作用顺序是: 物体空间 → 世界空间 → 视图空间 → 裁剪空间 → 屏幕空间。

### 投影
投影分为正交投影和透视投影，正交投影能够更好地反映比例，透视投影更加贴近真实。

方法是定义近和远两个平面，从一个平面投影向另一个平面。正交投影和透视投影的区别在于投影线是否平行，也就是投影面是否等大。

正交的计算方法形同平移，投影的坐标计算依赖于相似三角形。

$$y^{'}=\frac{n}{z}y$$

$$x^{'}=\frac{n}{z}x$$

n 和 z 分别是远平面和近平面到延长线和水平面交点的距离。

一个很好的资料是：[（超详细！）计算机图形学 入门篇 2. 视图变换（Viewing Transformations）](https://zhuanlan.zhihu.com/p/448547679)

#### 正交投影
正交投影的工作是将空间的长方体移动到原点并压缩成一个正方体。

有

$$
M_{ortho}=\begin{bmatrix}
\frac{2}{r-l}&0&0&0 \\
0 & \frac{2}{t-b} &0&0\\ 
0&0& \frac{2}{n-f} &0 \\
0&0&0&1
\end{bmatrix}
\begin{bmatrix}
1&0&0&- \frac{r+l}{2} \\
0&1&0&- \frac{t+b}{2} \\
0&0&1&- \frac{n+f}{2}\\
0&0&0&1 \\
\end{bmatrix}
$$

其中，(l,r)(b,t)(f,n)定义一个长方体，代表左右、上下、前后。

#### 透视投影
透视投影的工作是将远平面压缩成近平面等大，即将一个梯台变换为一个长方体。之后再进行正交投影就称为透视变换。

有

$$
M_{persp}=\begin{bmatrix}
n&0&0&0 \\
0&n&0&0 \\
0&0&n+f&-fn \\
0&0&1&0
\end{bmatrix}
$$

#### 总变换矩阵
先后进行透视投影和正交投影，得到总变换矩阵：

$$
M_{per}=M_{ortho}M_{persp}=\begin{bmatrix}
\frac{2n}{r-l}&0& \frac{l+r}{l-r}&0 \\
0& \frac{2n}{t-b} & \frac{b+t}{b-t}&0 \\
0&0& \frac{f+n}{n-f} & \frac{2fn}{f-n} \\
0&0&1&0 \\
\end{bmatrix}
$$

#### 另一种表述
有时我们偏向使用eye_fovy（垂向视角）和aspect_ratio（宽高比进行表述）。其中，

$$\frac{t}{n}=\tan{\frac{fovy}{2}}$$

$$aspect=\frac{t}{r}$$


### PA0
P点坐标（2，1），逆时针旋转45度，再平移（2，1），利用齐次坐标计算变换后的坐标。

```cpp
#include <cmath>
#include <eigen3/Eigen/Core>
#include <eigen3/Eigen/Dense>
#include <iostream>
#include <math.h>
#include <numbers>
#include <ostream>

using namespace std::numbers;

int main() {
  // 定义齐次坐标3维向量
  auto p = Eigen::Vector3f{2, 1, 1};
  //定义变换矩阵(3D)
  Eigen::Matrix3f r;
  r << cos(pi / 4), -sin(pi / 4), 2, sin(pi / 4), cos(pi / 4), 1, 0, 0, 1;
  std::cout << "Print R: " << std::endl;
  std::cout << r << std::endl;
  //计算变换后坐标
  p = r * p;
  //抛弃第3维，保留二维结果
  std::cout << "result print here" << std::endl;
  std::cout << "(" << p.x() << "," << p.y() << ")" << std::endl;
}
```

输出如下：
```sh
Print R: 
 0.707107 -0.707107         2
 0.707107  0.707107         1
        0         0         1
result print here
(2.70711,3.12132)
```

PA0 很容易，这里借 PA0 大致说一下环境配置问题：
1. 需要 eigen 和 opencv 两个库，推荐使用系统的包管理器下载: `paru -S eigen opencv`
2. opencv 可能由于路径问题（多出一个 opencv4 目录）无法找到库，建立一个软链接：`sudo ln -s /usr/include/opencv4/opencv2 /usr/include/`
3. 推荐使用 xmake 管理项目（当然你用 vs 或 cmake 也行），需要在 xmake. lua 中添加依赖 `set_requires("opencv")` 以及 `set_packages("opencv")`
4. 然后使用xmake编译和运行

### PA1
填写一个旋转矩阵和一个透视投影矩阵。给定三维下三个点 v0 (2.0, 0.0, −2.0), v1 (0.0, 2.0, −2.0), v2 (−2.0, 0.0, −2.0), 你需要将这三个点的坐标变换为屏幕坐标并在屏幕上绘制出对应的线框三角形。

> PS: 大概是我太弱，PA1 做得异常艰难，好不容易才弄懂。重要的大概就是几个变换矩阵，知道怎么推出来直接拿来用就好。再次鸣谢 [keanu大佬的笔记](https://zhuanlan.zhihu.com/p/448547679)！

模型变换代码如下：
```cpp
Eigen::Matrix4f get_model_matrix(float rotation_angle) {
  // 创建一个单位阵
  Eigen::Matrix4f model = Eigen::Matrix4f::Identity();
  Eigen::Matrix4f rotation;

  // 角度制转弧度制
  rotation_angle = rotation_angle * std::numbers::pi / 180;
  // 返回一个旋转矩阵，同齐次坐标的矩阵相乘
  rotation << cos(rotation_angle), -sin(rotation_angle), 0, 0,
      sin(rotation_angle), cos(rotation_angle), 0, 0, 0, 0, 1, 0, 0, 0, 0, 1;

  model = rotation * model;
  return model;
}
```

投影变换代码如下：
```cpp
// 给出的参数包括眼角和宽高比，近平面和远平面
Eigen::Matrix4f get_projection_matrix(float eye_fov, float aspect_ratio,
                                      float zNear, float zFar) {

  Eigen::Matrix4f projection = Eigen::Matrix4f::Identity();

  // 角度制转弧度制
  eye_fov = eye_fov * std::numbers::pi / 180;

  // 倒三角问题
  // 注意，此处的zNear和zFar传入的均是绝对值，表示相对屏幕的距离。需要转化为坐标
  // 由于看向的是-z方向，最后的变换矩阵w的1也需要改为-1

  float n = -zNear;
  float f = -zFar;
  float t = n * tan(eye_fov / 2);
  float b = -t;
  float r = t / aspect_ratio;
  float l = -r;

  Eigen::Matrix4f per;
  per << 2 * n / (r - l), 0, (l + r) / (l - r), 0, 0, 2 * n / (t - b),
      (b + t) / (b - t), 0, 0, 0, (f + n) / (n - f), 2 * f * n / (f - n), 0, 0,
      -1, 0;
  projection = per * projection;
  return projection;
}
```

## 光栅化
### 一些定义
#### 屏幕
二维数组，表示屏幕大小（像素多少），称为分辨率；典型的光栅（Raster，德语的 Screen）成像设备。

#### 像素（Pixel）
带有颜色的方块，屏幕的最小组成单位；rgb 的组合；内部不会发生颜色变化；

#### 屏幕空间
屏幕坐标系，将像素的坐标用 (x, y) 表示；(2, 1) 表示左 3 下 2 的像素（下标从 0 开始）。

#### 光栅化（Rasteriza）
将多边形绘画在屏幕空间上。

### 光栅成像设备
#### CRT 显示器
阴极射线管的缩写，电子偏移并打在屏幕上成像。利用隔行扫描技术，会造成画面撕裂，产生鬼影。

#### LCD 显示器
液晶显示器。通过液晶扭曲调整光的方向。

#### LED 显示器
LED 即发光二极管，与以上显示设备原理不同。使用小的发光二极管分别成像。

### 几何基础
三角形：多边形的基础，几乎所有实体都可以拆解成三角形；可以方便地利用叉积分别内外...

### 采样
函数的离散化。基本的采样过程是判断一个像素的中心是否在三角形内。在边界上，一些软件（OpenGL 等）规定上边和左边上的点在三角形内，下边和右边上的点在三角形外。

#### 采样理论

##### 走样
Artifacts，即采样产生的瑕疵、不准确和错误。常见的 artifacts 包括锯齿、摩尔纹、车轮效应，其中前两个是空间采样问题，后者是时间采样问题。**走样的原因是信号变化太快导致采样无法跟上（采样频率过低）。**

我们使用频率定义信号的变化速度，频率的倒数称为周期。

使用傅立叶级数展开可以将任何函数展开为一系列正弦/余弦函数和常数项的和。这里引出采样频率的概念，若采样频率太低，导致无法区分两个不同的函数，就导致走样。

##### 滤波
一个行之有效的反走样手段是 pre-fliter，即提前模糊处理，也称为**滤波**，然后进行采样。

傅里叶变换使时域转换为频域。中间表示低频信息（模糊图像），四周表示高频信息（表示边界）。

筛选信息的工具是滤波器。

##### 卷积
滤波等同于平均，等同于卷积操作。

卷积操作比较简单，滤波器在信号窗口上滑动，与对应位置求点积，记录中心位置结果。最终结果是一个像素自身及其周围像素的平均，从而达到模糊效果。时域卷积等于频域乘积（也就是低通滤波效果）。

一些结论：
1. 卷积核之和为 1
2. 卷积和越大越模糊

##### 采样
在时域上，相当于，原始连续函数乘以多个冲击函数（只在固定位置上有值，其他位置无值），从而得到一系列离散的点。

在频域上，相当于这两个函数的卷积。采样相当于重复原始频谱的过程。

采样越稀疏，在频域上越密集，频谱在搬移的情况下发生混叠，此即发生走样的原因。

#### 反走样
1. 增加采样率
2. 反走样：先模糊后采样，即先做高通滤波再采样（在频域上减少信号频谱宽度），方法是使用低通滤波器进行卷积操作

实际工业抗锯齿使用 MSAA 方法，得到抗锯齿效果。分割像素，得到 n\*n 个点。得到每个像素的覆盖率。缺点是增大了计算量。另外还有 FXAA（快速近似抗锯齿，原理是图像匹配抗锯齿）、TAA（时间抗锯齿，复用上一帧）方法。

另外一个概念是超分辨率。提高分辨率，实际还是为了解决样本不足的问题。常用 DLSS，用深度学习进行超采样。

### 可见性
可见性问题即解决多个物体遮挡的问题

#### 画家算法
依序从远到近作画，近处的物体覆盖远处的物体，从而解决遮挡问题。

但是无法处理存在互相遮挡关系的物体之间的深度关系，故不采用。

#### Z-Buffer
即深度缓存。通过遍历每个几何体，记录其每个像素的深度，在 buffer 中保留最浅深度。算法复杂度为 O (n)。伪代码如下，其中frameBuffer保存颜色信息，zbuffer保存深度信息。

```cpp
//初始化深度为正无穷
zbuffer[x,y]=infinity
for each Triangle T{
  for each sample (x,y,z) in T{
    //保留最小深度的深度和颜色信息作为该像素的参数
    if z<zbuffer[x,y]{
      frameBuffer[x,y]=rgb
      zbuffer[x,y]=z
    }
  }
}
```

算法假设不存在在同一像素上同深度的物体。

### PA2

1. 实现三角形栅格化算法；实现zbuffer算法
```cpp
// Screen space rasterization
void rst::rasterizer::rasterize_triangle(const Triangle &t) {
  auto v = t.toVector4();

  //   获取盒子的边界
  float left = width;
  float right = 0;
  float top = 0;
  float bottom = height;

  for (auto i : v) {
    left = std::min(i.x(), left);
    right = std::max(i.x(), right);
    top = std::max(i.y(), top);
    bottom = std::min(i.y(), bottom);
  }

  // 遍历盒子里面的每一个像素；
  // 此处因为一开始用auto，被识别成float，de了半天bug orz;
  for (int y = bottom; y < right; y++)
    for (int x = left; x < right; x++) {
      // 判断像素中心是否在物体中
      if (insideTriangle(x + 0.5, y + 0.5, t.v)) {
        // 被提供的代码，用来获得深度
        auto [alpha, beta, gamma] = computeBarycentric2D(x, y, t.v);
        float w_reciprocal =
            1.0 / (alpha / v[0].w() + beta / v[1].w() + gamma / v[2].w());
        float z_interpolated = alpha * v[0].z() / v[0].w() +
                               beta * v[1].z() / v[1].w() +
                               gamma * v[2].z() / v[2].w();
        z_interpolated *= w_reciprocal;
        int index = get_index(x, y);
        // 若是，记录深度和颜色
        if (z_interpolated < depth_buf[index]) {
          Vector3f p;
          p << x, y, z_interpolated;
          set_pixel(p, t.getColor());
          depth_buf[index] = z_interpolated;
        }
      }
    }
}
```
2. 测试点是否在三角形内
```cpp
// 用以判断点是否在三角形内
static bool insideTriangle(int x, int y, const Vector3f *_v) {
  // _v是数组，包含三个点，命名为A,B,C
  auto a = _v[0];
  auto b = _v[1];
  auto c = _v[2];
  // 定义该点为P
  Vector3f p;
  p << x, y, 1;
  // 计算(ab,ap),(bc,bp),(ca,cp)的叉乘，判断z符号是否相同
  auto v1 = (b - a).cross(p - a).z();
  auto v2 = (c - b).cross(p - b).z();
  auto v3 = (a - c).cross(p - c).z();
  return (v1 > 0 && v2 > 0 && v3 > 0) || (v1 < 0 && v2 < 0 && v3 < 0);
}
```
3. 映射变换继承 PA1

## 着色

### 定义
Shading，引入颜色和明暗。在图形学上指材质作用于物体。

### Blinn-Phong 反射模型
根据明暗不同可将物体分为三个区块，分别是高光、漫反射和环境光照。注意，该反射模型只是一个经验公式。

#### 漫反射
符合 Lambert's 余弦定律所表明的经验公式。其内容是：物体所吸收的光照与光线方向和物体表面法线之间夹角的余弦成正比。

有公式：

$$
L_{d}=k_{d}\left( \frac{I}{r^2} \right)max(0,\vec{n}\cdot{\vec{l}})
$$

其中，Ld 是漫反射光照强度，kd 是物体颜色（三通道的 rgb 值），第二项指示到达物体的光的强度，第三项即余弦值（且不为负，因为没有意义），指示物体接收到的光的强度。

漫反射的特点在于和观测方向无关，因为它均匀反射到各个方向。

#### 高光
观察方向与镜面反射方向足够接近时能够看到高光，或者说，法线方向与半程向量方向接近。半程向量即视线向量和光照向量的平均。

$$
\vec{h}=bisector(\vec{v},\vec{l})
$$

$$
L_{s}=k_{s}\left( \frac{l}{r^2} \right)max(0,\vec{n}\cdot{\vec{h}})^p
$$

其中，ks 是镜面反射系数。p 值通常取 100-200，p 值越大则高光区越小。

#### 环境光照
环境光照来自四周，与观测方向、光照方向无关，因此可被认为是常数，有经验公式：

$$
L_{a}=k_{a}I_{a}
$$

ka 是环境光照系数。

#### 着色模型

$$
L=L_{d}+L_{s}+L_{a}=k_{d}\left( \frac{I}{r^2} \right)max(0,\vec{n}\cdot{\vec{l}})+k_{s}\left( \frac{l}{r^2} \right)max(0,\vec{n}\cdot{\vec{h}})^p+k_{a}I_{a}
$$

### 着色方式
1. Flat shading/平滑着色：对三角形求法线，内部无颜色过渡
2. Gouraud shading：逐顶点着色，利用插值，着色效果较好
3. Phong shading：逐像素着色，利用插值，着色效果最好

着色频率取决于具体模型的复杂度，当面过于密集可能 flat shading 效果会更好。

### 图形/实时渲染管线
1. 顶点处理：空间上的点
2. 变换：形成三角形
3. 光栅化：采样和深度测试
4. 着色

### 着色编程
只需针对一个顶点或像素进行着色，称为顶点着色器或片段/像素着色器。

下面是一段 openGL GLSL 着色器例程：
```c
uniform sampler2D myTexture;
uniform vec3 lightDir;
varying vec2 uv;
//插值得到的顶点法线
varying vec3 norm;

void diffuseShader(){
  vec3 kd;
  // 物体颜色
  kd = texture2d(myTexture,uv);
  // 着色模型，其中clamp将值限制在0-1
  kd *= clamp(dot(-lightDir,norm), 0, 0, 1, 0);
  // 输出片段颜色
  gl_FragColor = vec4(kd,1,0);
}

```

#### 一些 API
shadertoy、openGL、directX

#### 硬件实现
GPUs。独立显卡和图形显卡。

GPU 核心数量等于可并行的数量。其并行度高，适合做图形学（简单、相似）计算。


### 纹理映射
纹理（texture）即一张图片，将这张图片蒙罩在物体表面即称为纹理。纹理和物体存在一一对应关系。映射方法是光栅和纹理坐标的对应。

纹理坐标系为 (u, v)，定义域为 (0, 1)。

### 插值

#### 为什么要插值
为了得到颜色的平滑过渡

#### 重心坐标

$$
(x, y)=\alpha A+\beta B+\gamma C
$$

$$
\alpha+\beta+\gamma=1
$$

$$
\alpha\geq 0 \quad \beta\geq 0 \quad \gamma\geq 0 
$$

由此，得到：

$$
V=\alpha V_{A}+\beta V_{B}+\gamma V_{C}
$$

其中，V_A, V_B, V_C 可以是位置、纹理、颜色、深度等

> 重心坐标在投影过程中会发生变化，因此应对三维属性在三维空间中做插值


### 纹理范围问题
#### 纹理过小
当纹理分辨率过低，屏幕像素映射到一个非整数纹理坐标，此时需应用双线性插值。

线性插值即在两个像素之间按比例进行插值，双线性插值即取周围邻近的四个像素按垂直和水平两个方向进行线性插值。

#### 纹理过大
会产生走样问题，近处产生锯齿，远处产生摩尔纹。

#### Mipmap
纹理大小的通用解决方法。生成一系列原图的缩放图，原图称为第一层，其他层较上层分辨率缩小一半。需要的额外存储空间仅为原图的三分之一。

对区域在纹理上投影的像素近似为一个正方形，令 L 为该正方形边长。则 Mipmap 层数为：

$$
D=\log_{2}{L}
$$

由于 Mipmap 是离散函数，会在边界产生不连续，因此需要在层与层之间再进行一次插值，配合水平和垂直的插值，称为三线性插值。

三线性插值在实时渲染中应用广泛，过渡连续，开销小。

但是三线性插值会产生 OverBlur 现象（远处模糊）。原因在与Mipmap使用正方形进行查询，解决方法有各向异性过滤（对应矩形区域查询有更好的效果，开销较高，是原图的三倍。对显存要求高），EWA过滤（使用圆形多次查询，效果好但代价高）

### PA3
PA3 主要包括以上章节的全部内容，难度稍高。其中 bump 和 displacement 着色器的实现有些超纲，故暂先不放出（可能留待后面补全）

#### 参数插值
第一部分投影变换与作业一、二一致，故不再说了。参数插值部分代码如下：

```cpp
// Screen space rasterization
void rst::rasterizer::rasterize_triangle(
    const Triangle &t, const std::array<Eigen::Vector3f, 3> &view_pos) {

  auto v = t.toVector4();
  int left = INT_MAX;
  int right = INT_MIN;
  int top = INT_MIN;
  int bottom = INT_MAX;
  for (auto p : v) {
    if (p.x() < left)
      left = p.x();
    if (p.x() > right)
      right = p.x();
    if (p.y() < bottom)
      bottom = p.y();
    if (p.y() > top)
      top = p.y();
  }
  for (auto x = left; x <= right; x++)
    for (auto y = bottom; y <= top; y++) {
      if (insideTriangle(x + 0.5, y + 0.5, t.v)) {
        // 得到重心坐标
        auto abg = computeBarycentric2D(x + 0.5, y + 0.5, t.v);
        // 使用get提取tuple中的元素
        auto alpha = std::get<0>(abg);
        auto beta = std::get<1>(abg);
        auto gamma = std::get<2>(abg);
        // 利用给出的公式计算zp
        //    * v[i].w() is the vertex view space depth value z.
        //    * Z is interpolated view space depth for the current pixel
        //    * zp is depth between zNear and zFar, used for z-buffer
        float Z = 1.0 / (alpha / v[0].w() + beta / v[1].w() + gamma / v[2].w());
        float zp = alpha * v[0].z() / v[0].w() + beta * v[1].z() / v[1].w() +
                   gamma * v[2].z() / v[2].w();
        zp *= Z;
        auto index = get_index(x, y);
        if (zp < depth_buf[index]) {
          // 颜色插值
          auto interpolated_color = interpolate(alpha, beta, gamma, t.color[0],
                                                t.color[1], t.color[2], 1);
          // 法向量插值
          auto interpolated_normal = interpolate(
              alpha, beta, gamma, t.normal[0], t.normal[1], t.normal[2], 1);
          // 纹理插值
          auto interpolated_texcoords =
              interpolate(alpha, beta, gamma, t.tex_coords[0], t.tex_coords[1],
                          t.tex_coords[2], 1);
          // 内部点位置插值
          auto interpolated_shadingcoords = interpolate(
              alpha, beta, gamma, view_pos[0], view_pos[1], view_pos[2], 1);

          fragment_shader_payload payload(
              interpolated_color, interpolated_normal.normalized(),
              interpolated_texcoords, texture ? &*texture : nullptr);
          payload.view_pos = interpolated_shadingcoords;
          auto pixel_color = fragment_shader(payload);
          set_pixel({x, y}, pixel_color);
          depth_buf[index] = zp;
        }
      }
    }
}
```

#### Phong 着色器
```cpp
Eigen::Vector3f phong_fragment_shader(const fragment_shader_payload &payload) {
  // 漫反射系数
  Eigen::Vector3f ka = Eigen::Vector3f(0.005, 0.005, 0.005);
  // 颜色系数
  Eigen::Vector3f kd = payload.color;
  // 高光系数
  Eigen::Vector3f ks = Eigen::Vector3f(0.7937, 0.7937, 0.7937);

  auto l1 = light\{\{20, 20, 20}, {500, 500, 500\}\};
  auto l2 = light\{\{-20, 20, 0}, {500, 500, 500\}\};

  std::vector<light> lights = {l1, l2};
  Eigen::Vector3f amb_light_intensity{10, 10, 10};
  Eigen::Vector3f eye_pos{0, 0, 10};

  float p = 150;

  Eigen::Vector3f color = payload.color;
  Eigen::Vector3f point = payload.view_pos;
  Eigen::Vector3f normal = payload.normal;

  Eigen::Vector3f result_color = {0, 0, 0};
  for (auto &light : lights) {
    // 出射光方向
    auto v = eye_pos - point;
    // 入射光方向
    auto l = light.position - point;
    // 半程向量
    auto h = (l + v).normalized();
    // r^2
    auto r2 = l.dot(l);
    auto Ld = kd.cwiseProduct(light.intensity / r2) *
              std::max(.0f, normal.normalized().dot(l.normalized()));
    auto Ls = ks.cwiseProduct(light.intensity / r2) *
              pow(std::max(.0f, normal.normalized().dot(h.normalized())), p);
    auto La = ka.cwiseProduct(amb_light_intensity);
    result_color += Ld + Ls + La;
  }

  return result_color * 255.f;
}
```

#### 纹理贴图
```cpp
Eigen::Vector3f
texture_fragment_shader(const fragment_shader_payload &payload) {
  Eigen::Vector3f return_color = {0, 0, 0};
  if (payload.texture) {
    //其他部分代码基本和Phong相同，只是多了获取纹理颜色的这部分
    return_color = payload.texture->getColor(payload.tex_coords.x(),
                                             payload.tex_coords.y());
  }
  Eigen::Vector3f texture_color;
  texture_color << return_color.x(), return_color.y(), return_color.z();

//...

```

### 凹凸贴图（Bump Textures）
凹凸贴图上一点 P 的切线为 (1, d_p)，其中 dp 为 u 变化一个单位，v 变化的值：

$$
d_{p}=c*(h_{p+1}-h_{p})
$$

则其法线为：

$$
(-d_{p}\ ,\ 1).normalized()
$$

在三维中：

$$
n=(  -\frac{d_{p}}{d_{u}},\  -\frac{d_{p}}{d_{v}},\ 1).normalized()
$$

### 位移贴图（Displacement Textures）
和凹凸贴图的区别在于，凹凸贴图并没有改变顶点的位置，而位移贴图则改变了，因此效果较好，但更加消耗性能。

### 纹理的其他应用
1. 噪声：可通过噪声函数实现裂缝、大理石之类的纹路。
2. 存储信息：记录已经计算好的着色，便于之后计算（提前计算）

## 几何

### 隐式表示法
#### 代数表示
使用数学公式定义一个形状，缺点在于复杂形状描述困难。有CSG（Constructive Solid Geometry），通过简单几何的运算（交并）得到复杂几何，建模软件广泛应用。

#### 距离函数
距离函数指空间上一个点到物体表面或边界的最小距离。对两个物体的距离函数进行运算，之后再转化为实体（取 f (x)=0 的点）。

#### 分形
递归方法

### 显式表示法
直接给出目标坐标和源坐标的映射关系，通过函数或参数映射的方式表述。

#### 点云
点云使用无数离散的点描述一个形体，它是一个 (x, y, z) 的列表，理论上能表述任何物体

#### 多边形面
常用三角形/四边形，可以表述很多几何体，应用最为广泛

> . obj 文件使用文本表示点的坐标、法线、纹理

### 曲线

#### 贝塞尔曲线
使用一系列的控制点定义一条曲线

![](https://picdl.sunbangyan.cn/2023/06/18/ix90zy.png)

贝塞尔曲线符合伯恩斯坦多项式：

$$
b^n(t)=\sum\limits^n\limits_{j=0}b_{j}B_{j}^n(t)
$$
对 n=3，
$$ b_{0}=(0,2,3) \quad b_{1}=(2,3,5)\quad b_{2}=(6,7,9)\quad b_{3}=(3,4,5)$$

有:

$$b^n(t)=b_{0}(1-t)^3+b_{1}3t(1-t)^2+b_{2}3t^2(1-t)+b_{3}t^3$$

性质：
1. 过起点和终点:$b(0)=b_{0}\quad b(1)=b_{3}$
2. $b'(0)=3(b_{1}-b_{0}) \quad b'(1)=3(b_{3}-b_{2})$
3. 仿射变换最终结果只与控制点有关
4. 凸包性：线上的任何一个点必在控制点围成的凸包之内

#### 逐段 (Piecewise) 贝塞尔曲线
为解决贝塞尔曲线难以控制的问题，每四个点定义一个（三次）贝塞尔曲线。

为保证两段曲线连续且光滑，要求两个端控制点重合，旁边的两个控制点共线。

C0 连续：两条曲线连续，即端点重合
C1 连续：切线连续，要求两个点（第一条曲线的 2 点和另一条曲线的 1 点）共线且距离相同

#### B 样条
对贝塞尔曲线的改进，避免改变一个点就会影响全部的缺点（具有局部性）

#### PA4
实现 de Casteljau 算法，代码很简单，但是请注意，你需要自己画出四个点才会出图 orz：

```cpp
cv::Point2f recursive_bezier(const std::vector<cv::Point2f> &control_points,
                             float t) {
  // Implement de Casteljau's algorithm
  // 使用递归实现
  if (control_points.size() == 1) {
    return control_points[0];
  }

  std::vector<cv::Point2f> next_control_points{};
  for (auto i = 0; i < control_points.size() - 1; i++) {
    auto p = (1 - t) * control_points[i] + t * control_points[i + 1];
    next_control_points.push_back(p);
  }
  return recursive_bezier(next_control_points, t);
}

void bezier(const std::vector<cv::Point2f> &control_points, cv::Mat &window) {
  // Iterate through all t = 0 to t = 1 with small steps, and call de
  // Casteljau's recursive Bezier algorithm.
  for (auto t = .0; t <= 1.0; t += 0.001) {
    auto p = recursive_bezier(control_points, t);
    window.at<cv::Vec3b>(p.y, p.x)[1] = 255;
  }
}
```

### 曲面/网格

曲面即曲线的延伸。在两个方向上分别定义贝塞尔曲线，从而得到贝塞尔曲面。

#### 网格优化
1. 网格细分：增加三角形
2. 网格简化
3. 网格正则化

#### 网格细分
##### loop 细分
1. 细分：从三角形三边中点将三角形分为四部分
2. 调整三角形各顶点的位置：新顶点的值是其周围四个点的平均（加权 1/8 和 3/8）；老顶点的值是其周围顶点和它自己的值的加权

##### Catmull-Clark 细分
概念：
1. 四边形面和非四边形面
2. 奇异点：度不为 4 的点

非四边形面在一次 Catmull-Clark 细分后转化为奇异点，非四边形面消失。

![](https://picdl.sunbangyan.cn/2023/06/18/uc1da7.png)

#### 网格简化
目标是减少网格数量同时维持大体的形状

其中一种方法是边坍缩，边选择的手段是二次误差度量。二次误差度量即计算点到各边的距离的平方之和，使它的值最小。因为一条边的坍缩可能影响其他边，需要使用优先队列确定坍缩的顺序。

## 光线追踪

### Shadow Mapping
#### 步骤
1. 从光源看向场景，记录深度
2. 从相机看向场景，投影回光源，比较记录的深度是否一致，若不同，则在阴影中。

#### 缺点
1. 浮点数由于存在数值精度问题，在判定相等时存在困难
2. 分辨率过小出现锯齿，分辨率过大则开销大

### 光线追踪概论

#### 为什么使用光线追踪
1. 光栅化无法很好展示全局效果，包括软阴影、镜面反射、间接光照等
2. 光栅化虽然速度快但质量较低
3. 光线追踪质量高、真实性好，但生成慢，一般用于非实时渲染

#### 光线的假设
1. 光线沿直线传播
2. 光线之间不发生冲突
3. 光线的路径是从光源到人眼，且具有可逆性

#### 光线追踪过程
1. 从眼睛出发的一条光线（eye ray）指向物体，产生一个交点，记录最小的深度
2. 该交点与光源连线，判断是否被光源可见，从而判断是否在阴影中，然后计算着色

#### Whited 风格光线追踪
对玻璃材质的物体，eye ray 在与物体相交时，会发生反射和折射（并发生能量损失），所有光线与物体的交点均作与光源的连线，每个交点的着色均会加到图像平面的像素中去。

![](https://picdl.sunbangyan.cn/2023/06/19/ly52ub.png)


### 光线与物体求交
#### 光线与隐式表面求交
光线上一点 $r(t)={o}+t{d}\quad 0\leq t<\infty$

其中，t 表示光传播的时间

球上一点 p: $(p-c)^2-R^2=0$

则 $({o}+td-c)^2-R^2=0$

依据求根公式可求得 t。

#### 光线与显式表面（三角形）求交
##### 光线与平面求交

平面定义：平面上一点 p，有 $(p-p')\cdot \vec{N}=0$ ，p'是平面上的一个点，N 是平面的法线

得到 $t=\frac{{(p'-o)\cdot \vec{N}}}{d\cdot\vec{N}}$

然后与光线方程联立

此种方法的缺点是当三角形数量过多时计算量特别大，因此对于显然不会通过物体的情况，引入包围盒（AABBs）加速计算

##### 光线与包围盒求交
1. 只有当光线进入全部的三组对立面时才认为它进入盒子
2. 当光线离开任何一组对立面时认为它离开盒子

对每一组对立面，有 t_max 和 t_min 分别是较大的交点和较小的交点

此时，进入时间等于 max{t_min}，离开时间等于 min{t_max}

当且仅当 t_enter < t_exit && t_exit >= 0 时，光线与包围盒有交

###### 均匀空间划分
<img src="https://picdl.sunbangyan.cn/2023/06/21/111qjjh.png" />

对大包围盒进行平均划分成多个小包围盒。我们认为光线与包围盒求交要远快于与物体或三角形面求交。因此，将光线与小包围盒求交，如果通过的某个包围盒中存储有物体，则光线可能通过物体，此时做光线与格子中存在的物体求交。

对包围盒的划分数量，划分太少则加速效果不明显，太多则可能拖累计算

###### 其他空间划分

平均空间划分适合平面内均布有大量三角形的情况，但对三角形分布密集的情况会产生不必要的划分，因此产生了其他的划分方法：

- Oct-Tree：每次将空间分为平均的八份，然后对子空间递归，形成一个八叉树
- KD-Tree：每次将空间分为两份，然后沿三个坐标轴进行递归划分，形成二叉树
- BSD-Tree：与 BD-Tree 类似，但不再沿坐标轴，可任意划分，形成二叉树

对于 KD-Tree，当求光线与物体的交点时，需遍历 KD-Tree，判断光线与子节点是否有交，对于有交的节点，递归判断子节点。

对于此种方法，一个物体可能会存在于多个盒子中，因此需要在树中存储多个同样的物体；另外，KD-Tree 的建立并不简单。因此这种方法并没有被广泛使用。

相对于对空间进行划分，对物体进行划分应用更为广泛，此种方法被称为 BVH。

###### BVH
![](https://picdl.sunbangyan.cn/2023/06/21/124yhkh.png)

BVH的过程是：先找到一个包围盒，将包围盒的物体划分为两堆，然后重新计算包围盒，再对子包围盒进行递归计算。

BVH 能够很好地避免 KD-Tree 产生的一个物体出现在多个子节点中的问题，但是包围盒会产生重叠，因此划分方法十分重要。

### 辐射度量学

辐射度量学是为了更合理、科学地描述光照，它提供了光照的数个属性：radiant flux（辐射通量），intensity（光强），irradiance（辐射照度），radiance（辐射亮度）。

> 这里提到了知识掌握的有效方法：Why, What and How，其中 How 是相对最无用的。私以为确实如此，不知道 Why 就不清楚学习的意义，也无法活用；不知道 What 就相当于没学；至于 How 则是细节问题，完全可以需要时再加以掌握。

#### 概念
Radiant Energy：辐射能量，用 Q 表示，单位是 J

Radiant Flux / Power：辐射通量，表示单位时间能量，$\phi=\frac{dQ}{dt}$，单位是 W

Radiant Intensity：辐射强度，$I(\omega)=\frac{d\phi}{d\omega}$，其中 omega 是立体角（球上的面积除以半径的平方，即空间上的角度定义），表示单位角度能量

Irradiance：单位面积上接收到的能量，$E=\frac{\phi}{4\pi}$，可用以解释光强衰减

Radiance：描述某确定的微小面对某个立体角辐射的能量，或某个微面在某个立体角接收的能量，相当于 Intensity per unit area 或 Irradiance per solid angle, 与 Irradiance 区别在于 Radiance 具备方向性。$L(p,\omega)=\frac{dI(p,\omega)}{dA\cos \theta}$ 。Irradiance 可以通过 Radiance 积分得到。

![](https://picdl.sunbangyan.cn/2023/06/22/825lr.png)



#### BRDF
即反射方程，描述某个方向入射光反射所得到的出射光。

![](https://picdl.sunbangyan.cn/2023/06/22/d8gec.png)

#### 渲染方程
对于发光物体，它对某方向出射的光等于其发出的光和反射的光之和。因此，所有情形可由下式表述，这是现代图形学的基础：

![](https://picdl.sunbangyan.cn/2023/06/22/in8an.png)

求解过程是一系列数学推导掠过……总之结果是光照可以分解为弹射 n 次（n>=0）次的光线权和，导致全局光照收敛到某一亮度。

### 路径追踪

#### Whited Style Ray Tracing 存在的问题

1. 能够体现 Mirror Reflection，却无法很好表示 Glossy Reflection（有些粗糙的材质）。模型：犹他茶壶
2. 停留在漫反射，无全局光照。模型：康奈尔盒子，常用于测试全局光照效果。

#### 路径追踪过程

借助蒙特卡罗积分，可求出直接光照：

![](https://picdl.sunbangyan.cn/2023/06/22/m1s4i0.png)

对于间接光照，类比直接光照的计算方法，但观察者变成了第一个物体：

![](https://picdl.sunbangyan.cn/2023/06/22/m4o97m.png)

但是此时如果光线数量过多，会存在指数爆炸问题，因此我们假设每个点在递归中只弹射一条光线，即 N=1 。当且仅当 N=1 时称为路径追踪：

![](https://picdl.sunbangyan.cn/2023/06/22/m6frgg.png)

为了使用递归，必须确定退出条件。使用俄罗斯轮盘赌，每次弹射有 P 概率存活。可以通过此种方式用有穷的递归达到无穷的同等期望。

![](https://picdl.sunbangyan.cn/2023/06/22/szckni.png)

到此已经差不多完备了，但仍存在一些问题：我们对着色点各个方向的立体角进行采样，其射出的光线存在不能打到光源、因此没有用处的冗余。通过改变积分域，建立立体角和光源界面的关系，然后对光源进行采样，可以有效避免该问题：

![](https://picdl.sunbangyan.cn/2023/06/22/tupflr.png)

![](https://picdl.sunbangyan.cn/2023/06/22/ty82uq.png)

## 材质与表面

> 本章的目的是使用BDRF重新解释着色

漫反射材质将入射光线均匀反射到各个方向，我们认为入射和出射光线存在能量守恒，则反射方程可以转化为以下形式：

![](https://picdl.sunbangyan.cn/2023/06/22/ulhxh6.png)

然后我们定义 rho 为反射率，rho 范围为 (0, 1)。

另外还有金属光泽材质（Glossy）和理想反射/折射材质、全反射材质（入射角度和出射角度相同）、镜面折射材质（入射角和出射角正弦比等于折射率）。

### 菲涅尔项

入射光与法线的夹角决定有多少能量被反射，由菲涅尔项表示。由于公式过于复杂，故在要求不高时使用近似公式：

![](https://picdl.sunbangyan.cn/2023/06/22/vhlshc.png)

### 微表面模型

微表面模型认为从近处看到的是几何，从远处看则几何消失，变成外观。也就是说，在近处可认为有无数小的微表面，光线在微表面上发生镜面反射。


![](https://picdl.sunbangyan.cn/2023/06/22/xbadal.png)

微表面模型 BRDF 如图所示，F 项为菲涅尔项，决定有多少能量被反射；D 项决定法线分布；G 项称为几何项，决定有多少光线（几乎平行入射的光线）会发生子投影和子遮挡，修正用。

### 各向同性/各向异性
各向同性与各向异性取决于微表面分布是否与方向有关，各向同性与方向无关，各个地方微表面分布相同；各向异性与方向有关。

## 高级渲染主题
### 高级光线传播

两种无偏路径追踪：BDPT、MLT；两种有偏路径追踪：光子映射、VCM（Vertex connnection and merging）

#### 双向路径追踪（BDPT）
从光源和相机分别发出半路径，再将半路径端点连接起来。

适合光源处光线传播复杂的情况，但实现困难，且计算缓慢。

#### Metropolis（MLT）
通过在一个 path 周围产生新的 path 样本找出全部 path。

因为只需要一条path，特别适合复杂场景的路径追踪。

缺点在于很难估计收敛，结果噪点多，很难用以生成动画。

#### 光子映射（Photon Mapping）
能够很好地表现 Castics 现象

光子映射过程如下：

1. 光子追踪：从光源出发，记录光子经反射和折射后最后停留的位置
2. 光子收集：从相机出发，发出 sub-path，记录反射和折射后最终停留的位置
3. 局部密度估计：对每个着色点，找出其最近的 n 个光子，计算其所占据的面积，从而得到光子的密度：n/area

光子映射是一种有偏但一致的方法：只要着色点不是无限多，结果必定存在模糊；但着色点无限多则必定真实。

#### VCM
BDPT 和光子映射的结合

#### Instant Radiosity（IR）
认为被照亮的点可以被看做光源。

优点在于快且结果质量较好，但在窄的/缝隙场景会发光，且无法渲染 Glossy 物体


### 高级表面模型

> 定义材质即定义该材质与光线如何作用

#### 非表面模型

##### 散射介质
对于云、雾等散射介质，光进入介质中会发生反射和折射，可使用路径追踪计算

##### 毛发
人的头发模型：玻璃柱模型

三种头发模型：R（光线在毛发表面反射）、TT（光线穿透毛发）、TRT（光线穿透毛发并在内壁反射回来）

对于动物毛发，与人的头发模型不一致。动物毛发中髓质较大，更加容易发生反射。故提出双层圆柱模型（是的，就是讲师提出的模型！），以描述髓质与光线的作用。与人的头发模型不同的是，动物毛发多出两个散射模型：TTs 和 TRTs，描述被髓质散射的光线。

##### Granular 模型（颗粒模型）
通过小的颗粒构图，缺点在于时间开销大

#### 表面模型
##### 半透明材质
符合次表面反射模型（BSSRDF），可采用 Dipole 方法近似计算。

![](https://picdl.sunbangyan.cn/2023/06/22/10elqjx.png)

##### 布料

布料由纤维缠绕而成，分为几个层级：纤维缠绕形成股、股缠绕形成线、线编织成布料。

具体渲染方法有如下几种：

1. 通过编制图案可以得到 BRDF 模型，从而进行渲染。
2. 分割空间为无数个格子，从而将布料当成云、雾等反射介质处理，结果真实但计算量极大。
3. 分别渲染每一个纤维。缺点同上。

## 相机、透镜、光场
### 相机
组成部分：快门（shutter）、传感器（sensor，记录irradiance）

针孔摄像机：利用小孔成像原理，拍出的相片无景深

FOV：视场，相机拍摄的角度

![](https://picdl.sunbangyan.cn/2023/06/23/m1tnho.png)

FOV 可由传感器高度和焦距计算得出，因此焦距越短视角越大。一般用焦距衡量视场，它是对应 35mm 大小胶片的焦距。

#### 曝光

H (曝光度)=T (曝光时间) xE (Irradiance)

曝光时间由快门控制。具体影响因素如下：

1. 光圈大小：改变 f-stop（称为f数，f数越小光圈越大）
2. Shutter speed：控制光进入的时长
3. ISO 增益/感光度：对结果进行增益和修正

![](https://picdl.sunbangyan.cn/2023/06/23/m890nx.png)

##### ISO
ISO 对图像进行后期处理，通过对图像乘以一个增益，能够增加图像的曝光度，但是会增加图像的噪声。

##### f 数
即光圈直径的倒数，可以控制同一时间进入相机的光量，从而直接调整曝光度。

##### 快门
直接控制光进入的时间（曝光时间）。

当物体在快门打开时存在运动，由于传感器的平均作用，会发生模糊现象，称为运动模糊。因此，更长的曝光时间会产生更严重的运动模糊。

而相对更少的曝光时间会导致更低的曝光度，可通过更大的F数进行补偿。

由于快门打开过程需要一定时间，当物体运动速度快于快门打开的时间，会产生扭曲现象（如拍摄高速旋转的螺旋桨），称为 Rolling Shutter 现象。

#### 场景
##### 高速摄影
高速摄影需要非常短的曝光时间，曝光度较低，因此需要大光圈。

##### 长曝光相片
长曝光导致曝光度高，因此需要小光圈。

### 镜头
#### 透镜

对于理想的薄（凸）透镜，平行光照射到棱镜上会汇聚的焦点；过焦点的光线必定会变成平行光；棱镜的焦距可以被改变。

![](https://picdl.sunbangyan.cn/2023/06/23/n9cif1.png)


得到 $\frac{1}{f}=\frac{1}{z_{i}}+\frac{1}{z_{o}}$

![](https://picdl.sunbangyan.cn/2023/06/23/ncdxuq.png)

$$
C=A\frac{{|z_{s}-z_{i}|}}{z_{i}}=\frac{f}{N}\frac{{|z_{s}-z_{i}|}}{z_{i}}
$$

CoC 原理是一个点由于屏幕在成像点之后，导致产生一个模糊的圈；圈的大小与光圈大小成正比。

透镜的光线追踪较简单，只需计算光线的折射方向，并记录在屏幕上的位置即可。

#### 景深
景深的定义是存在的一个范围，它在成像平面附近形成的区域 CoC 足够小，使成像清晰。

![](https://picdl.sunbangyan.cn/2023/06/23/niyddk.png)

### 光场（Light Field）
#### 全光函数

$$
P(\theta,\phi,\lambda,t,V_{X},V_{Y},V_{Z})
$$

全光函数定义光线的方向（极坐标）、光的波长（颜色）、时间、人/相机的位置，从而定义了一个 3D 全息场景。

光场即场景中所有可能的光的位置和方向：

![](https://picdl.sunbangyan.cn/2023/06/23/nyeyrb.png)

光场照相机即应用光场原理，使用微透镜，允许进行后期调校。

## 颜色与感知

### 光谱

![](https://picsh.sunbangyan.cn/2023/06/24/so08ky.png)

其中可见光的范围在 400nm-700nm 之间。

### 谱功率密度（SPD）
SPD 可描述光强在不同波长处的分布，SPD 存在可加性。

### 颜色
颜色是人眼的感知，并非SPD，因此也存在个体差异。

视网膜上存在感光细胞，分为棒状细胞和锥形细胞。棒状细胞感知光的强度，锥形细胞感知颜色。锥形细胞又分为 S、M、L，其感知光的波长不同，用数值表示如下：

![](https://picdl.sunbangyan.cn/2023/06/23/p3gibr.png)

### 同色异谱现象
SPD 不同但最终得到的颜色（SML）相同，称为同色异谱现象。而这也是颜色匹配/混合的基础。我们通常使用 RGB 三色进行加色得到各种颜色。

CIE RGB 提出了一个颜色匹配函数，其三原色数值可为负，能够混合出任何颜色。该色彩空间称为 sRGB（Standard RGB）。

#### 色彩空间

##### CIE XYZ
CIE 提出的一类颜色系统，其中 X、Z 表示不同颜色，Y 表示亮度。对其进行归一化处理，可将其定义在 (0, 1) 的一个色域之中，有 x=X/(X+Y+Z)，下同。由于 Y 表示亮度，可以固定 y，从而使颜色匹配函数转化为 x 和 z 的函数。

##### 色域
色域是一个颜色空间所有可能表示的颜色。

##### 其他色彩空间
- HSV：颜色拾取器，色调（Hue）、饱和度（Saturation）、亮度（Value）
- CIELAB：定义互补色，L（亮度）、a 轴（红或绿）、b 轴（蓝或黄）
- CMYK：三种彩色+黑色


## 计算机动画
### 动画的定义
1. Bring things to life，使图片动起来
2. 建模的扩展，更好地展示模型的运动

### 历史
1. 从科学研究到娱乐业：奔跑的马
2. 手绘动画：白雪公主与七个小矮人
3. 数字动画：遥控的精确作图
4. CG：玩具总动员

### 关键帧动画
关键帧（keyframes）：一些重要的帧，可定义动画的走向。其他帧称为关键帧的过渡。

### 物理仿真
利用牛顿力学公式进行仿真 F=ma

流程是先模拟后渲染

#### 质点弹簧系统

![](https://picdb.sunbangyan.cn/2023/06/24/lzup97.png)

![](https://picda.sunbangyan.cn/2023/06/24/m3r182.png)

考虑到弹簧的损耗，假设 a 不动，可计算 b 上的力。

质点弹簧系统的应用：绳子模型、头发模型

#### 粒子系统
粒子之间存在引力、斥力、摩擦力等...

$F=\frac{Gm_{1}m_{2}}{d^2}$

![](https://picsw.sunbangyan.cn/2023/06/24/sogox1.png)

粒子系统本质在于定义个体与群体的关系。以鸟群模拟为例，一只鸟会本能地融入群体，但不会太过靠近，同时会朝向鸟群行进方向飞行。

### 运动学

#### 正运动学（骨骼系统）
关节分为三类：Pin（1D）、Ball（2D）、Prismatic Joint（translation）

通过定义每个关节从而计算出每一个部位的位置参数

缺点在于定义贴近物理（需要调节角度），导致艺术家使用困难；优点在于直观、计算方便

#### 逆运动学
定义运动的轨迹，自动计算出关节的位置和角度。

逆运动学可能出现多解和无解问题


### Rigging
Rigging 即控制模型做出动作。

通过控制点改变模型姿态和动作。

动作捕捉：易于得到大量真实的数据，但装置复杂昂贵，无法得到动画戏剧性效果


### 产品流水线
![](https://picdo.sunbangyan.cn/2023/06/24/qs4bls.png)


## 模拟
### 欧拉方法
场上任何一点在某一时刻的速度已知，称其为速度场：v (x, t)，即：

$\frac{dx}{dt}=\dot{x}=v(x,t)$

对下一帧的位置和速度，可从上一帧的位置、速度、加速度求出，称为欧拉方法：

![](https://picsh.sunbangyan.cn/2023/06/24/qz69ca.png)


欧拉方法存在以下问题：

1. 欧拉方法由于是数值方法，所以存在误差，步长越小则误差越小。
2. 欧拉方法由于是离散的，即使步长取得再小误差也必定会无限累积，导致其不稳定。

#### 中点法
一种欧拉方法的不稳定性的解决方法：

![](https://picsl.sunbangyan.cn/2023/06/24/r3xxdw.png)

1. 先计算一遍欧拉方法，此时到达点 a
2. 取中点，考虑中点在场中的速度进行修正，然后再次计算一遍欧拉方法

其本质是引入一个二次项，使欧拉方法更加稳定。

#### 自适应方法

![](https://picdg.sunbangyan.cn/2023/06/24/solwka.png)

通过中点进行二分递归计算，若两次模拟结果相似则不再递归，使最终呈现出自适应步长。

#### 隐式欧拉方法

![](https://picdp.sunbangyan.cn/2023/06/24/r8135e.png)

隐式欧拉方法的区别在于后一帧的位移/速度使用前一帧的位移/速度以及后一帧的速度/加速度计算。

由于参数并非线性，所以求解困难；但能够提供更好的稳定性。

#### 误差的衡量方法

局部截断误差：每一步产生的误差
整体误差：全局的误差

隐式欧拉方法的误差是一阶，局部误差是O(h^2)，整体误差是O(h)

#### 隆戈库塔方法
用来解常微分方程，特别适用于求解非线性方程，最常用的是四阶。

![](https://picdc.sunbangyan.cn/2023/06/24/s51tjt.png)

### Position-Based/Verlet Method
不基于物理，直接修改位置，非能量守恒，但计算很快

一个例子是水体的模拟。抽象水体为许多不可压缩的小球，只要确定每个小球的位置，确定其分布，即可模拟出水体的形态。由于水的密度不变，因此可基于密度对小球的位置进行修正，这就用到了 Position-Based 方法。

### 刚体模拟
对欧拉方法的扩充

![](https://picsp.sunbangyan.cn/2023/06/24/s7sdqf.png)


### 拉格朗日方法
拉格朗日方法也称质点法，其关注某个质点随时间的参数变化；而欧拉方法也称网格法，其关注某个空间内某点在某时间的参数。

MPM（Material Point Method）是一种结合拉格朗日方法和欧拉方法的方法。

## 未来可能的一些学习话题
- 光栅化：现在可以学习和掌握 OpenGL、DirectX 等，甚至手写着色器！
- 几何：掌握数学基础，微分几何、离散微分几何、拓扑...
- 光线传播
- 模拟仿真：Games201