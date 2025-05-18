---
title: 使用sing-box配置hysteria2以及reality客户端与服务端
created: 2025-01-09 23:38:49
---
## 前言

很长一段时间都在使用 nekoray/nekobox 作为代理客户端，但是 nekoray 很久没有更新了，而且 sing-box 1.11.0 版本已经支持 hysteria2 的端口转发，因此决定转移到 sing-box 上。因为使用自建节点，而 sing-box 的 gui 都不尽如人意，所以使用 sing-box cli 作为客户端。后来将服务端也转移到 sing-box，以便于多个代理的维护。本文记录一下整个过程。

## 客户端

### 环境

- 发行版：Debian 11
- Sing-box 版本：1.11.22 Beta

### 配置文件

这里是一个 hysteria2 和 reality 的配置文件，你可以直接使用，但是注意修改 outbound 的 ip 以及端口等信息（前提是已在服务器部署有相关服务，未部署的可以看下面的服务端篇）。

其中 dns 主要配置 dns 的解析规则；inbounds 配置入站，这里采用 tun 的方式进行透明代理，但是使用这种方式要求管理员权限；outbounds 配置出站，分别是各个代理的具体配置以及选择器。Route 配置路由，主要应用 clash 模式以及规则集；experimental 中主要是缓存以及 clash API 的配置。

```yaml
{
  "dns":
    {
      "servers":
        [
          { "tag": "cf", "address": "https://1.1.1.1/dns-query" },
          { "tag": "local", "address": "223.5.5.5", "detour": "direct" },
          { "tag": "block", "address": "rcode://success" },
        ],
      "rules":
        [
          { "outbound": "any", "server": "local" },
          { "rule_set": "geosite-cn", "server": "local" },
        ],
      "strategy": "ipv4_only",
    },
  "inbounds":
    [
      {
        "type": "tun",
        "address": "172.19.0.1/30",
        "auto_route": true,
        "strict_route": false,
      },
    ],
  "outbounds":
    [
      {
        "type": "selector",
        "tag": "proxy",
        "outbounds": ["hysteria2", "reality"],
        "default": "hysteria2",
      },
      {
        "type": "hysteria2",
        "tag": "hysteria2",
        "server": "<服务器IP>",
        "server_port": <监听端口>,
        "server_ports": "<跳跃端口，类似10000:20000>",
        "up_mbps": 0,
        "down_mbps": 0,
        "password": "<密码>",
        "tls": { "enabled": true, "server_name": "bing.com", "insecure": true },
      },
      {
        "type": "vless",
        "tag": "reality",
        "server": "<服务器IP>",
        "server_port": <监听端口>,
        "uuid": "<UUID，与服务端相同>",
        "flow": "xtls-rprx-vision",
        "network": "tcp",
        "tls":
          {
            "enabled": true,
            "reality":
              {
                "enabled": true,
                "public_key": "公钥，与服务端私钥匹配",
                "short_id": "短id，与服务端相同",
              },
            "server_name": "www.tesla.com",
            "utls": { "enabled": true, "fingerprint": "chrome" },
          },
      },
      { "type": "direct", "tag": "direct" },
    ],
  "route":
    {
      "rules":
        [
          { "action": "sniff" },
          { "protocol": "dns", "action": "hijack-dns" },
          { "ip_is_private": true, "outbound": "direct" },
          { "clash_mode": "Direct", "outbound": "direct" },
          { "clash_mode": "Global", "outbound": "proxy" },
          { "rule_set": "geosite-category-ads-all", "action": "reject" },
          { "rule_set": ["geoip-cn", "geosite-cn"], "outbound": "direct" },
        ],
      "rule_set":
        [
          {
            "tag": "geoip-cn",
            "type": "remote",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs",
            "download_detour": "proxy",
          },
          {
            "tag": "geosite-cn",
            "type": "remote",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs",
            "download_detour": "proxy",
          },
          {
            "tag": "geosite-category-ads-all",
            "type": "remote",
            "format": "binary",
            "url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite/category-ads-all.srs",
            "download_detour": "proxy",
          },
        ],
      "auto_detect_interface": true,
    },
  "experimental":
    {
      "cache_file": { "enabled": true, "store_rdrc": true },
      "clash_api":
        { "external_controller": "127.0.0.1:9090", "external_ui": "ui" },
    },
}

```

### 客户端控制

我发现当我使用代理程序时，使用频率比较高的大概是以下几个操作：

- 开启代理
- 关闭代理
- 切换代理

#### 开启代理

为了方便地开启代理，在根目录下写了如下脚本：

1. `sing-box.bat`

```batch
@echo off
start "" /b "%~dp0sing-box.exe" "run" "-c" "%~dp0config.yaml"
exit
```

2. `sing-box.vbs`

```vbs
Dim ws
Set ws = CreateObject("Wscript.Shell")
ws.run "cmd /c <Your Path>\sing-box.bat",vbhide
```

前者负责运行 sing-box，后者负责移除 cmd 窗口。

然后创建一个快捷方式，这里注意快捷方式的目标（target）需要修改为：`C:\Windows\System32\wscript.exe <Your Path>\sing-box.vbs`，并且使用管理员权限执行。

将这个快捷方式加入到环境变量中，然后通过 Powertoys Run 调用。

#### 关闭代理

PowerToys Run 有一个非常好用的插件，名叫 ProcessKiller，顾名思义，能够杀掉进程，很像 Linux 下的 pkill 命令，插件的 GitHub 地址如下：[Process Killer](https://github.com/8LWXpg/PowerToysRun-ProcessKiller)

然后将插件的激活命令设置为 `kl`，唤出 PowerToys Run，输入 `kl sing-box<Enter>` 即可杀掉代理。

#### 切换代理

由于 sing-box 支持 clash API，所以可以通过 API 进行代理的切换，而 sing-box 提供了一个 Web ui，可以通过该 Web ui 进行代理切换。

```json
"clash_api":
    { "external_controller": "127.0.0.1:9090", "external_ui": "ui" },
},
```

以上配置提供了该功能。

## 服务端

对于服务端，可以使用我所编写的脚本：[hysteria2-reality-install-script](https://github.com/levinion/hysteria2-reality-install-script)。具体操作大致如下：

### 1. 将仓库克隆到本地

```shell
git clone https://github.com/levinion/hysteria2-reality-install-script
```

### 2. 安装 just

```shell
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/bin
```

### 3. 安装 sing-box

```shell
cd hysteria2-reality-install-script
just install_singbox
```

### 4. 随机生成配置

```shell
just generate
```

配置文件（.env）文件会生成在当前目录下，可按需修改（非强制）

### 5. 安装证书、生成 sing-box 配置文件、配置端口跳跃、优化系统参数

```shell
just install
```

### 6. 可选：配置防火墙

```shell
apt install ufw
just ufw
systemctl enable ufw --now
```

### 7. 运行

```shell
just enable
```

### 8. 可选：生成客户端 Outbounds 示例

```shell
just outbounds
```

该命令会生成对应的客户端 outbound 配置，复制到客户端配置文件中即可。

### 9. 停止运行

```shell
just disable
just stop
```

### 10. 更新配置以及重新运行

```shell
just reload
```
