---
title: 从ufw迁移到nft
created: 2025-12-05 16:48:48
---
## UFW

用了很长时间的ufw，它最大的好处在于易学易用。

可以使用一行命令来开放端口，如：

```shell
ufw allow 80/tcp
```

或是一次开放多个端口：

```shell
ufw allow 3000-5000/udp
```

甚至

```shell
ufw allow ssh
```

但是ufw也有痛点，如不支持原子更新。在搭配ansible使用时：

```yaml
- name: ensure ufw is installed
  ansible.builtin.package:
    name: ufw
    state: present
    update_cache: yes

- name: reset ufw
  community.general.ufw:
    state: reset

- name: allow ssh
  community.general.ufw:
    rule: allow
    name: OpenSSH

- name: enable ports
  community.general.ufw:
    rule: allow
    port: "{{ item }}"
    proto: any
  loop:
    - 80
    - 8443

- name: enable ufw
  community.general.ufw:
    state: enabled
    policy: deny
```

由于需要清除已开放的端口，需要在重新设定规则前执行 ufw reset。而这会导致防火墙在短暂时间内处于完全开放状态。另外，由于reset会清空防火墙，因此防火墙状态会改变。即使并没有修改端口，每次执行playbook时都会引起防火墙重设。

因此，我们需要一种声明式而非命令式的方式来配置防火墙。

## nftables

nftables是iptables的继任者。ufw在背后也在使用nftables。通过nft脚本，可以实现防火墙策略的原子更新。

以下是一个nft配置的示例：

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    # Allow established connections
    ct state established,related accept

    # Allow loopback
    iif lo accept

    # Allow SSH from management network
    ip saddr 192.168.1.0/24 tcp dport 22 accept

    # Allow tcp ports
    tcp dport { 80, 443 } accept
    
    # Allow tcp ports
    udp dport { 80, 443 } accept
  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

## 使用ansible配置nftables

为了使用ansible来配置nftables，创建一个名为nftables的角色（role），然后创建一些必要文件：

```
nftables
├── handlers
│   └── main.yaml
├── tasks
│   └── main.yaml
└── templates
    └── nftables.conf.j2
```

在`tasks/main.yaml`中，定义任务逻辑如下：

```yaml
- name: make sure nftables is installed
  ansible.builtin.package:
    name: nftables
    state: present
    update_cache: yes

- name: generate conf
  ansible.builtin.template:
    src: nftables.conf.j2
    dest: /etc/nftables.conf
    owner: root
    group: root
    mode: "0640"
  vars:
    tcp_ports:
      - 80
      - 8443
    udp_ports: []

  notify:
    - restart nftables

- name: run service
  ansible.builtin.service:
    name: nftables
    state: started
    enabled: yes
```

即：

- 安装nftables
- 生成配置文件
- 启用nftables服务

在`templates/nftables.conf.j2`中创建配置文件的模版如下（只是稍微改编了下上面的配置）：

```yaml
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority 0; policy drop;

    ct state established,related accept

    iif lo accept

    ip saddr 192.168.1.0/24 tcp dport 22 accept

  {% if tcp_ports %}
    tcp dport { {{ tcp_ports | join(', ') }} } accept
  {% endif %}

  {% if udp_ports %}
    udp dport { {{ udp_ports | join(', ') }} } accept
  {% endif %}

  }

  chain forward {
    type filter hook forward priority 0; policy drop;
  }

  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

在`handlers/main.yaml`中定义重启nftables的操作：

```yaml
- name: restart nftables
  ansible.builtin.service:
    name: nftables
    state: reloaded
  ignore_errors: true
```

在根目录的playbook.yaml中引用这个role即可：

```shell
- name: some task
  hosts: some servers
  roles:
    - ...
    - "roles/nftables"
    - ...
```

## 后话

在使用nftables后，防火墙策略能够原子更新，这意味着有语法错误的配置并不会导致防火墙策略的改变。但是，错误的配置仍有可能被应用，毕竟nft也不知道你想要做什么。

因此，在应用之前，最好再三确认配置的正确性。对于远程主机，最重要的是确保不要把sshd端口屏蔽了，特别是在没有使用默认的22端口的时候。
