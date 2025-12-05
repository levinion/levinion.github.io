---
title: 使用sing-box给Alice IPv6小鸡加上v4出口
created: 2025-12-05 12:30:47
---
昨天收了只Alice IPv6免费小鸡，但是由于没有v4, 导致许多网站访问不了。比如github，直到2025年仍不支持IPv6访问。虽然可以通过更改hosts解决，见 (https://www.nodeseek.com/post-531425-1)，但毕竟不是长久之策，我们还需要访问其他网站。

好在Alice为免费小鸡提供了免费的双栈代理出口，我们可以通过这个出口获取到完整的流媒体解锁和IPv4服务。

Github上已经有人做出了一键脚本，用来切换出口，它使用tun2socks实现，详见：

```
https://github.com/hkfires/onekey-tun2socks
```

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

大善人Alice的免费机是极好的挂针机，毕竟它免费（包括机器和流量），而且也不需要定期登录保活。拿来用的话，由于线路并不好，电信和联通都会绕路，且移动丢包不少，因此体验并不好。因此只建议移动用户作为落地使用，其他人拿来玩玩就好。

虽然国内大力在推进IPv6，但在国际上仍不是那么普及，因此目前纯IPv6小鸡还是处于一种很尴尬的境地。