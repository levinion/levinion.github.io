---
title: komari部署
created: 2025-11-08 15:03:08
---
[komari](https://github.com/komari-monitor/komari)是一个服务器监控工具（mjj们一般称为探针）面板，对于手持多个服务器的人十分友好。

## 安装komari

komari采用一种前后端分离的架构，前端，也就是面板，需要自托管，因此需要一个域名以及一台比较稳定的服务器。

采用github上提供的一键脚本安装即可，这会自动开启服务：

```shell
curl -fsSL https://raw.githubusercontent.com/komari-monitor/komari/main/install-komari.sh -o install-komari.sh
chmod +x install-komari.sh
sudo ./install-komari.sh
```

然后这可以通过`http://<your_server_ip>:25774`访问。

## DNS配置

然后需要配置DNS，从而通过域名进行访问。这可以通过购买域名的网站进行设置。

虽然我在spaceship购入，但仍然将其托管到了[cloudflare](https://dash.cloudflare.com/)，因为能够使用cloudflare的小云朵（免费的SSL）服务。

## Nginx配置

设置完毕域名解析后，只需配置nginx，listen 80端口，并将对域名的访问重定向到`http://<your_server_ip>:25774`。

如果未安装过nginx，参考：

```shell
apt install nginx
systemctl enable --now nginx
```

安装完毕后，创建一个配置文件：`/etc/nginx/sites-available/komari`，然后填入以下内容：

```nginx
server {
        listen 80;
        server_name <your domain name>;

        location / {
                proxy_pass http://127.0.0.1:25774;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "Upgrade";
                proxy_buffering off;
                client_max_body_size 50M;
        }
}
```

将其链接到`/etc/nginx/sites-enabled/`：

```shell
ln -s /etc/nginx/sites-available/komari /etc/nginx/sites-enabled/
```

测试一下配置：

```shell
nginx -t
```

重新加载配置文件：

```shell
nginx -s reload
```

注意，如果配置了防火墙还需放行80端口。以`ufw`为例：

```shell
ufw allow 80
```

此时已经可以通过`https://<your domain name>/`进行访问。

然后在面板中添加服务器，并按照提示使用bash脚本在服务器上安装agent即可。

## 其他

如果你不使用cloudflare的小云朵服务，则需要一些额外步骤以开启HTTPS支持。这边有一篇很好的文章：https://idcflare.com/t/topic/18769.

如果你使用小云朵，但按照上面这篇文章去配置nginx，会发现网页无法正常打开，浏览器提示503重定向次数过多。这是由于这部分内容：

```nginx
server {
    listen 80;
    server_name tz.linux.do; # 你设置的A解析的域名
    return 301 https://$server_name$request_uri;
}
```

这将http请求重定向到了https请求，如果不开启小云朵，这是正确的。小云朵开启后，当用户发送了一个http请求，在DNS解析阶段，cloudflare将该请求重定向到https给浏览器，但始终向服务器发送http请求。如果此时nginx再将http请求重定向到了https，则又会造成cloudflare的重定向，从而导致重定向的死循环。

因此，要么不开启小云朵，并申请本地证书；要么就开启小云朵，享受cloudflare的便捷服务吧。