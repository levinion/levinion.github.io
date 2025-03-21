---
title: Docker-and-Kubernetes-学习笔记
created: 2023-04-17 18:05:10
---

## 概论

### 为什么是 docker
为简化软件的安装和使用

### 什么是 docker
docker = docker client（docker cli） + docker server（docker daemon）

### 容器和镜像
- 镜像是一个单独的文件，其保存用以实现服务的必要配置和步骤。镜像可以被认为是一个文件系统的快照，同时包含着一个非常具体的启动命令。

- 容器是镜像的具体运行实例。

### 实现机理
docker 容器实际运行在一个 linux 虚拟机中，并且通过命名空间、控制组实现权限管理。当从镜像创建容器时，镜像的文件系统快照被复制到容器，并且通过启动指令进行运行。

## docker 命令

### 从镜像中创建和启动一个容器
1. 创建容器，并执行默认启动命令
```sh
docker run <image name>
```

2. 覆写启动命令
```sh
docker run <image name> <some command>
```

### 列出所有运行中的容器
1. 列出所有运行中的容器
```sh
docker ps
```

`docker ps` 列出所有运行中的容器的信息，包括 ID、镜像、命令、运行时长、状态、端口、名称等。

2. 列出曾经运行过的所有容器
```sh
docker ps --all
```
