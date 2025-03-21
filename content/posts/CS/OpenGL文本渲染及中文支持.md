---
title: OpenGL文本渲染及中文支持
created: 2025-03-11 21:47:28
---
## 文本渲染流程

对于文本渲染，首先我们需要引入`freetype`库。它主要实现了从字形文件生成位图的功能，从而方便生成材质以供文本渲染。

```cpp
#include <ft2build.h>
#include <freetype/freetype.h>
#include FT_FREETYPE_H
```

总共涉及的初始化包括三部分，分别是freetype、shader和vao、vbo的初始化：

```cpp
void init(std::string font) {
  this->init_freetype(font);
  this->init_shader();
  this->init_buffer();
}
```

对freetype进行一些初始化工作：

```cpp
// 初始化freetype
FT_Library ft;
FT_Init_FreeType(&ft)

FT_Face face;
FT_New_Face(ft, font.c_str(), 0, &face)

// 设置字体尺寸
FT_Set_Pixel_Sizes(this->face, 0, 48);
// 禁用字节对齐限制
glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
```

初始化shader：

```cpp
void init_shader() {
  // 导入shader代码，生成和使用program
  auto vertex = (const char*)_text_vertex_shader_code;
  auto fragment = (const char*)_text_fragment_shader_code;
  auto shader = Shader(vertex, fragment);
  this->shader = shader;
  shader.use();
  
  // 设置投影矩阵
  auto app = Application::get_instance();
  auto size = app->window_size();
  glm::mat4 projection = glm::ortho(
    0.0f,
    static_cast<float>(size.first),
    0.0f,
    static_cast<float>(size.second)
  );
  glUniformMatrix4fv(
    glGetUniformLocation(shader.id(), "projection"),
    1,
    GL_FALSE,
    glm::value_ptr(projection)
  );
}
```

shader代码如下：

```glsl
// vertex.glsl
#version 330 core
layout(location = 0) in vec4 vertex; // <vec2 pos, vec2 tex>
out vec2 TexCoords;

uniform mat4 projection;

void main()
{
    gl_Position = projection * vec4(vertex.xy, 0.0, 1.0);
    TexCoords = vertex.zw;
}

// fragment.glsl
#version 330 core
in vec2 TexCoords;
out vec4 color;

uniform sampler2D text;
uniform vec3 textColor;

void main()
{
    vec4 sampled = vec4(1.0, 1.0, 1.0, texture(text, TexCoords).r);
    color = vec4(textColor, 1.0) * sampled;
}
```

进行vao和vbo初始化：

```cpp
void init_buffer() {
  // init vao
  unsigned int vao;
  glGenVertexArrays(1, &vao);
  // init vbo
  unsigned int vbo;
  glGenBuffers(1, &vbo);
  glBindVertexArray(vao);
  glBindBuffer(GL_ARRAY_BUFFER, vbo);
  glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 6 * 4, NULL, GL_DYNAMIC_DRAW);
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * sizeof(float), 0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
  glBindVertexArray(0);
}
```

为每个字符生成一个材质，并且存储该字符到材质的映射以供后续使用：

```cpp
void TextGenerater::add_character(char32_t c) {
  FT_Load_Char(this->face, c, FT_LOAD_RENDER)
  // 创建材质
  unsigned int texture;
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RED,
    face->glyph->bitmap.width,
    face->glyph->bitmap.rows,
    0,
    GL_RED,
    GL_UNSIGNED_BYTE,
    face->glyph->bitmap.buffer
  );
  // 材质参数
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  // 保存字符参数
  Character character = {
    texture,
    glm::ivec2(face->glyph->bitmap.width, face->glyph->bitmap.rows),
    glm::ivec2(face->glyph->bitmap_left, face->glyph->bitmap_top),
    (unsigned int)face->glyph->advance.x
  };
  // 创建字符到材质映射
  this->character_table.insert(std::pair<char32_t, Character>(c, character));
}
```

最后就可以进行字体渲染：

```cpp
void draw_text(
  std::string text,
  float x,
  float y,
  float scale,
  Color color
) {
  this->shader.use();
  // 字体颜色
  glUniform3f(
    glGetUniformLocation(this->shader.id(), "textColor"),
    color.r,
    color.g,
    color.b
  );
  // 启用材质
  glActiveTexture(GL_TEXTURE0);
  glBindVertexArray(vao);

  // 将utf8转换为utf32字符串，即unicode
  std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t> utf32conv;
  auto s = utf32conv.from_bytes(text);

  // 遍历渲染字符
  for (auto c = s.begin(); c != s.end(); c++) {
    // 如果未找到字符则动态载入
    if (!this->character_table.contains(*c)) {
      this->add_character(*c);
    }
    auto ch = this->character_table[*c];

    float xpos = x + ch.bearing.x * scale;
    float ypos = y - (ch.size.y - ch.bearing.y) * scale;

    float w = ch.size.x * scale;
    float h = ch.size.y * scale;
    // 字体渲染的位置
    float vertices[6][4] = { { xpos, ypos + h, 0.0f, 0.0f },
                             { xpos, ypos, 0.0f, 1.0f },
                             { xpos + w, ypos, 1.0f, 1.0f },

                             { xpos, ypos + h, 0.0f, 0.0f },
                             { xpos + w, ypos, 1.0f, 1.0f },
                             { xpos + w, ypos + h, 1.0f, 0.0f } };
    // 绑定字符材质
    glBindTexture(GL_TEXTURE_2D, ch.texture_id);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(vertices), vertices);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // 水平移动，以渲染下一个字符
    x += (ch.advance >> 6)
      * scale;
  }
  glBindVertexArray(0);
  glBindTexture(GL_TEXTURE_2D, 0);
}
```

## 中文渲染

对于中文渲染，主要需要修改的地方在于：

1. 英文只需要128个字符，与之相对中文（cjk）则需要更多，因此需要使用`char32_t`或`wchar_t`替换`char`。
2. 同理，需要使用`std::wstring`替换`std::string`，或是使用以下方法进行格式转换：

```cpp
std::wstring_convert<std::codecvt_utf8<char32_t>, char32_t> utf32conv;
auto s = utf32conv.from_bytes(text);
```

3. 另外，由于unicode字符非常多，因此无法一次性完成材质创建，需要进行动态载入。在绘制实际字符时进行判断：

```cpp
if (!this->character_table.contains(*c)) {
    this->add_character(*c);
}
```