---
title: 使用sing-box给Alice IPv6小鸡加上v4出口
created: 2025-12-05 12:30:47
---
昨天收了只Alice IPv6免费小鸡，但是由于没有v4, 导致许多网站访问不了。比如github，直到2025年仍不支持IPv6访问。

好在Alice为免费小鸡提供了免费的双栈代理出口，我们可以通过这个出口获取到完整的流媒体解锁和IPv4服务。

Github上已经有人做出了一键脚本，用来切换出口，它使用tun2socks实现，详见： https://github.com/hkfires/onekey-tun2socks

但我们也可以用sing-box来统一实现。

## 安装sing-box

sing-box是一个全平台的代理工具。安装方法也很简单，使用官方提供的一键脚本即可：

```shell
curl -fsSL https://sing-box.app/install.sh | sh
```

## 创建配置文件

配置文件应放到`/etc/sing-box/config.json`

```json
{
  "log": {
    "level": "info"
  },
  "inbounds": [
    {
      "type": "tun",
      "address": [
        "172.19.0.1/30",
        "fdfe:dcba:9876::1/126"
      ],
      "route_exclude_address": "::/0",
      "auto_route": true,
      "strict_route": false,
      "mtu": 9000,
      "stack": "mixed"
    }
  ],
  "outbounds": [
    {
      "type": "selector",
      "tag": "proxy",
      "outbounds": [
        "alice",
        "direct"
      ],
      "default": "alice"
    },
    {
      "type": "socks",
      "version": "5",
      "tag": "alice",
      "server": "2a14:67c0:116::1",
      "server_port": 10008,
      "username": "alice",
      "password": "alicefofo123..OVO"
    },
    {
      "type": "direct",
      "tag": "direct"
    }
  ],
  "route": {
    "final": "proxy",
    "rules": [
      {
        "action": "sniff"
      },
      {
        "protocol": "dns",
        "action": "hijack-dns"
      },
      {
        "ip_is_private": true,
        "outbound": "direct"
      },
      {
        "clash_mode": "Direct",
        "outbound": "direct"
      },
      {
        "clash_mode": "Global",
        "outbound": "proxy"
      }
    ],
    "rule_set": [],
    "auto_detect_interface": true
  },
  "experimental": {
    "cache_file": {
      "enabled": true,
      "store_rdrc": true
    },
    "clash_api": {
      "external_controller": "0.0.0.0:80",
      "external_ui": "ui",
      "secret": "d45cd022-29ae-4629-8022-f71a0c3c208a"
    }
  }
}
```

其中，socks5节点具体内容如下：

```json
{
    "type": "socks",
    "version": "5",
    "tag": "alice",
    "server": "2a14:67c0:116::1",
    "server_port": 10008,
    "username": "alice",
    "password": "alicefofo123..OVO"
}
```

如果Alice没有对该节点做任何改动，直接使用即可。其中端口从以下任选其一：

```
台湾家宽 #1:10001
台湾家宽 #2:10002
台湾家宽 #3:10003
台湾家宽 #4:10004
台湾家宽 #5:10005
台湾家宽 #6:10006
台湾家宽 #7:10007
台湾家宽 #8:10008
```

## 服务

为了便于管理，如果你使用带systemd的系统，可以在`/etc/systemd/system/`中创建一个`sing-box-server.service`文件：

```ini
[Unit]
Description=Sing-Box Server Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/sing-box run -c /etc/sing-box/config.json
WorkingDirectory=/etc/sing-box/
User=root
Group=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true
Restart=always

[Install]
WantedBy=multi-user.target
```

然后启用服务：

```shell
systemctl enable --now sing-box-server
```

检查一下是否启动成功：

```shell
systemctl status sing-box-server
```

看一下是否能够检测到IPv4地址：

```shell
❯ curl -6 ip.sb
36.230.*.*
```

## 后话

大善人Alice的免费机是极好的挂针机，毕竟它免费（包括机器和流量），而且也不需要定期登录保活。拿来用的话，由于线路并不好，电信和联通都会绕路，且移动丢包不少，因此直连体验并不好。只建议作为落地解锁使用。

V6环境确实在好起来。如cloudflare就提供了双栈CDN，使得v6机器能够正常接受来自v4地址的流量访问，因此能够获得和普通v4机器相似的建站体验。并且由于v6相对v4廉价机器更多，相信未来更多的网站会建在v6机器上。

另外，如果不使用提供的socks节点，也可以通过warp来获取v4出口。使用：

```shell
wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh go
```

然后可以选择全局模式默认使用warp作为分流节点，或是使用sing-box来自行决定分流规则。

如果只是想要访问github而不需要添加v4，将以下内容添加到`/etc/hosts`末尾: 

```shell
2a01:4f8:c010:d56::2 github.com
2a01:4f8:c010:d56::3 api.github.com
2a01:4f8:c010:d56::4 codeload.github.com
2a01:4f8:c010:d56::6 ghcr.io
2a01:4f8:c010:d56::7 pkg.github.com npm.pkg.github.com maven.pkg.github.com nuget.pkg.github.com rubygems.pkg.github.com
2a01:4f8:c010:d56::8 uploads.github.com
2606:50c0:8000::133 objects.githubusercontent.com www.objects.githubusercontent.com release-assets.githubusercontent.com gist.githubusercontent.com repository-images.githubusercontent.com camo.githubusercontent.com private-user-images.githubusercontent.com avatars0.githubusercontent.com avatars1.githubusercontent.com avatars2.githubusercontent.com avatars3.githubusercontent.com cloud.githubusercontent.com desktop.githubusercontent.com support.github.com
2606:50c0:8000::154 support-assets.githubassets.com github.githubassets.com opengraph.githubassets.com github-registry-files.githubusercontent.com github-cloud.githubusercontent.com
```

详见： https://www.nodeseek.com/post-531425-1