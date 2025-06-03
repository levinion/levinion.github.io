systemd从根本上来说是一个`init`工具，负责初始化系统。然后，作为系统的第一个进程，它也理所应当地充当了管理其他进程的职责。

systemd提供了`systemctl`命令，用来管理进程。

```shell
systemctl enable
systemctl start
systemctl stop
systemctl restart
systemctl disable
systemctl reload
```

可以通过service文件来具体控制systemd如何控制一个进程。

systemd在系统层面的service文件遵循以下路径（优先级从高到低）：

- /etc/systemd/system
- /run/systemd/system
- /usr/lib/systemd/system

如openssh就附带了如下的service文件，从而允许systemd控制sshd的执行：

```shell
[Unit]
Description=OpenSSH Daemon
Wants=sshdgenkeys.service
After=sshdgenkeys.service
After=network.target

[Service]
Type=notify-reload
ExecStart=/usr/bin/sshd -D
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
```

`After`表示该unit应在某个service或target启动之后运行。对于多个unit，它可以像上面那样分开写，也可以使用空格分隔，类似这样：

```shell
After=sshdgenkeys.service network.target
```