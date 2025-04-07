---
title: Firefox QA
created: 2025-01-20 22:17:34
---

## 前言

因为最近 chrome 的 UI 渲染出了些问题，于是瞟了眼火狐。

以前就想要转移到火狐，但因为没找到比 chrome 更舒服的网页翻译功能，所以被劝退。最近发现了一款名为“沉浸式翻译”的翻译插件，提供了类似chrome页面内翻译的功能，于是终于能够转移到火狐了。

第一印象是：真的快。当然这也可能是插件比较少的原因。使用了几天，发现了一些相比chrome的不足之处。但火狐可定制性较强，经过一定的配置之后，大多问题都能得到解决。本篇就记录一下发现的问题与解决方式。

## 版本

Firefox Developer Edition 135.0b6（64位）

## QA


以下设置均在`about:config`中进行。

### 1. 显示语言为中文

ED版本默认没有除英文外的其他界面显示语言选项，需要在`about:config`里面开启以下两个选项。

`intl.multilingual.enabled`

`intl.multilingual.downloadEnabled`

然后在设置中添加中文，并移动到首位。

### 2. 关闭进入全屏提示

视频全屏会有一条横幅提示进入全屏，我认为这是不必要的，因此进行设置以删除。

`full-screen-api.warning.timeout`设置为0

### 3. 全屏过渡动画太长

进入和离开全屏会有一段黑屏渐变动画，如果嫌弃它太过冗长，可以加快播放速度：

`full-screen-api.transition-duration.enter`设置为`30 50`

`full-screen-api.transition-duration.leave`设置为`30 50`

如果想要完全关闭，设置为`0 0`；不建议这么做，因为屏幕会出现短暂闪烁。

### 4. 媒体音量小

火狐的默认音量较其他浏览器更小，这导致同时开启火狐和其他软件时的音量不统一。可以通过安装600%声音增强插件来单独更改页面的声音，但这仍然有些麻烦。因此可以通过以下配置修改全局音量比例：

`media.volume_scale`设置为1.5或2.0

### 5. 禁止错误恢复

当火狐处于运行状态并关机时，再次开机并打开火狐会提示无法恢复之前页面，而个人习惯并不需要恢复，并且也未设置打开以前页面选项。这个问题可以通过设置以下配置解决：

`browser.sessionstore.resume_from_crash`设置为`false`

### 6. 跳过可执行文件检查

默认情况下当一个pdf下载完毕后，打开前会触发这个告警，禁用它。

将`browser.download.skipConfirmLaunchExecutable`设为True（布尔值），如果不存在则创建。

### 7. 允许音视频自动播放

设置界面 > 隐私 > 默认选项 > 选择允许自动播放

### 8. 调整缩放

对于火狐，进入about:config界面，修改`layout.css.devPixelsPerPx`属性。

### 9. 允许拓展运行在受保护页面

清除`extensions.webextensions.restrictedDomains`中的相应页面

设置`privacy.resistFingerprinting.block_mozAddonManager`为`true`

### 10. userChrome.css

将`toolkit.legacyUserProfileCustomizations.stylesheets`设为`true`

创建`~/.mozilla/firefox/<profile-id>/chrome`文件夹，`profile-id`可以在`about:profiles`页面中找到

在目录下创建`userChrome.css`文件，并使用`@import`引用自定义css文件。类似：

```css
@import "./css/tabs_below_content_v2.css";
```

然后在指定位置编写css文件。对于一些常用的css，推荐这个repo：<https://github.com/MrOtherGuy/firefox-csshacks>，或是它提供的搜索界面：<https://mrotherguy.github.io/firefox-csshacks/>

### 11. 强制启用硬件解码

如果使用N卡，安装驱动以支持libva：

```shell
paru -S libva-nvidia-driver
```

当然，也可以安装`libva-utils`以检测当前显卡的支持情况。

为了在火狐中强制启用硬件解码，将`gfx.webrender.all`设为`true`

## 其他

### 一些插件

- ublock origin
- bitwarden
- dark reader
- 600% sound volume / SoundFixer
- vimium
- new tab overide
- immersive translate

### 设置为默认浏览器（xdg-open）

```shell
xdg-settings set default-web-browser firefox-developer-edition.desktop
```