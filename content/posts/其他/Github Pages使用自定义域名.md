---
title: Github Pages使用自定义域名
created: 2025-01-14 21:05:52
---
## 前言

有个域名闲置了，放着也是放着，于是想着把博客转到这个域名上，但又想使用 Git 进行管理，幸好 GitHub Pages 提供了自定义域名功能。

## 流程

1. 增加 DNS 记录

对于一级域名，需要添加 A 记录指向 GitHub Pages 的服务器 IP；本次使用的是二级域名，二级域名只需要增加一条 CNAME 记录即可。CNAME 记录即是一个主机别名，它指向一个域名，缓存有该域名对应的服务器 IP。像我的情况，只要配置 `blog.maruka.top` 指向 `levinion.github.io` 即可。

2. CNAME 文件

在页面根目录（主页 `index.html` 同级目录）中新建一个 CNAME 文件，内容为新的域名，比如 `blog.maruka.top`。

3. 添加自定义域名

在 GitHub Pages 页面（repo 的设置界面中）中，添加域名，比如 `blog.maruka.top`。

4. 打开 HTTPS

打开 Enforce HTTPS 功能，GitHub Pages 会自动配置证书。这需要等待 DNS 记录更新才可用。如果你使用 cloudflare 的 dns 服务，务必取消橙色小云朵，否则可能会导致"Unavailable for your site because your domain is not properly configured to support HTTPS"错误。过一段时间，GitHub Pages 会自动配置证书，然后就可以开启 HTTPS 服务了。
