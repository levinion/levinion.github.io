---
title: MIT6.824-分布式系统
created: 2023-03-24 23:14:57
---
## Lecture 01 - Intro

分布式系统是指在多台计算机之间协调同步计算的系统体系，它与运行在单台计算机上的非分布式系统形成对比。人们运行分布式系统的目的是获得多台计算机提供的强大**性能**以及提高出于地理等不可控条件下的兼容性和人为导致的**容错性**。而对于没有对算力和容错性有较高要求的用户来说，分布式系统的开发和使用可能是复杂而低效的。

分布式系统所基于的基本架构有**存储、通信和计算**。分布式系统应提供简单的接口方便第三方应用调用其基本架构；其目标是通过抽象的接口将其分布式特性隐藏起来，使应用如在非分布式系统上那样运行。RPC 和线程是构建分布式系统的常用工具。

### 1. 可扩展性

分布式系统的可扩展性意味着通过增加计算机数量的手段提升系统性能，但是当计算机增加到某种程度时就会出现瓶颈。

### 2. 容错

衡量分布式系统容错的指标包括**可用性**和**自我恢复性**。可用性是指在系统在发生错误后依然能够正常运行，这通常是通过拷贝做到的。自我恢复性是指能够通过人为干预使系统恢复正常。容错的实现主要借助两点，一是非易失存储，二是复制。对使用复制实现容错的系统来说，管理是最大的困难所在。

### 3. 一致性

一致性即用来定义操作系统行为的概念；强一致保证拿到的是最近一次修改的数据，但是实现其的通信成本十分高昂。应用构建更倾向于使用弱一致性以获取更好的性能。

## Lecture 02 - MapReduce

MapReduce 是由谷歌设计开发和使用的分布式系统框架，其理念是让工程师专注于应用程序的核心，框架则负责计算机的组织和计算的分发以及故障处理等工作。在 MapReduce 框架中，整个 MapReduce 的计算称为 Job，每次 MapReduce 的调用称为 Task。一个完整的 MapReduce Job 由一些 Map Task 和 Reduce Task 组成。Map 函数负责接受文件输入，其输出是一个 k-v 对。在 Job 的最开始对每一个输入运行 Map 函数，结果有 MapReduce 框架负责收集并提交给 Reduce 函数。

Map 函数接受值是一个 k-v 对。emit 是属于 Map 函数，其由 MapReduce 框架提供。在用 MapReduce 实现的简单单词计数器应用中，对每一个单词调用一个 emit 函数，其接受值同样是一个 k-v 对，分别表示单词和数量。

Reduce 函数接受一个 k-v 对，其中 value 是一个数组，包括 Map 函数输出的 key 对应的全部实例。其同样含有一个 emit 函数，该 emit 会作为 Reduce 函数的最终输出。

## Lecture 03 - GFS

人们设计分布式系统的初衷是获取多台计算机的计算量，因此需要将数据进行分隔以放到多台计算机上，此过程称为**分片**。分片的存在对容错提出要求，而容错最简单的方式即是复制。复制则带来不一致的问题。为解决不一致的问题，服务器之间进行通信和交互，因而降低性能。
对一个理想的强一致性系统来说，客户端似乎只与一台服务器通信；该系统同一时间只处理一个请求，并且以单线程处理事务。强一致性要求两个服务器存取的表单完全一致，这意味着写数据将对两个服务器同时进行，而只从一台服务器读取数据。但由于无法保证两台服务器以相同的顺序处理请求，当有两个写数据请求时，这就可能导致两台服务器表单数据的不一致。想要修复该问题就意味着更多的通信和更高的复杂度。

GFS（Google File System）是谷歌构建的快速大型全局文件存储系统。单个文件会被自动分片存储在多台服务器内，以获得更大的存储量和更高的聚合吞吐量。它能够自动恢复，做到较好的容错；但由于一些限制，并没有分散布局，而集中在一个数据中心之内。GFS 作为谷歌内部使用的系统，并不直接面向普通用户。GFS 是一个专为大型文件存取提供服务的系统，它对文件进行顺序读写而不支持随机访问。其目的是获得更大的吞吐量而不关注延时。GFS 论文提出了存储系统弱一致性的可行性，其并不保证返回正确的数据，从而对客户端数据校验提出需求。

### Master 节点

GFS 架构包括一个 Master 服务器和多个 Chunk（块）服务器，每个 Chunk 服务器具有 1-2 个磁盘。Master 节点用于管理所有文件和 Chunk 服务器，其返回文件和 Chunk 服务器的对应关系；Chunk 服务器负责存储实际数据。

Master 节点保存的数据内容包括两个表单。第一个表单保存**文件名到 Chunk ID 或 Chunk Handle 数组的对应**；第二个表单记录 **Chunk ID 到 Chunk 数据的关系**，具体包括 Chunk 服务器列表，Chunk 对应版本号，主 Chunk 和租约。为保证重启后数据恢复，Master 节点只从内存读取数据，并且在数据变动时在磁盘的 log 中追加记录，创建存档点（Check Point）。其中，Chunk Handle 数组及 Chunk 版本号应记入 log，而其他数据则不需要。
Master 节点维护 log（顺序读写） 而非数据库（随机读写）是为了方便其追加，当节点重启时，其从 log 中最近一次存档点恢复数据。

### 文件读写

对于读的情况来说，客户端先将文件名和偏移量（指示从文件哪个位置开始读取）发送 Master；Master 返回给客户端 Chunk Handle（ID）及服务器列表；客户端从列表中选择一个节点进行连接，对选定节点发送 Chunk Handle 和偏移量；服务器使用 Linux 文件系统查找文件（文件以 Chunk Handle 命名），从文件中读取数据段并发送客户端。

对写的情况来说，客户端向 Master 节点发起请求询问文件中最后一个 Chunk 的位置。由于写文件必须从 Primary Chunk 写入，当主副本不存在时，Master 会找出存有最新 Chunk 副本（版本号与 Master 记录一致）的服务器列表。Master 节点由版本号来判断 Chunk 的最新副本，当版本号丢失，就无法判别 Chunk 的新旧，这也是为何版本号被保存在非易失介质上的原因。然后 Master 节点下发版本号，并分配一个 Primary 节点，并将更新 Chunk 的权限交托；其余作为 Secondary 节点。（Primary 节点存在租约，这意味着 Primary 节点存在更替，并且同一时间不会有两个 Primary 节点）Primary 节点每次接受一个客户端请求，判断磁盘容量并写入数据，同时通知其他 Secondary 节点更新数据。假如有 Secondary 写入失败，会由 Primary 向用户发送写入失败，客户端应重新发起整个写入过程，即：与 Master 交互，得到文件末尾 Chunk，再向 Primary 和 Secondary 发起追加请求。

通常在写文件的过程中，默认有三个副本，包括一个 Primary 和两个 Secondary，它们对一个文件负责。

### GFS 的一致性

GFS 是**弱一致**的，这表现在并发写入时，当一个写入请求失败，客户端再次请求写入时，可能导致信息的乱序。这要求客户端在文件中写入序列号，做到自行检测；或是针对特定数据停止并发写入。

### GFS 的一些缺陷

1. GFS 最大的缺陷在于只有一个 Master 节点。
2. 由于 Master 节点为每个文件和 Chunk 维护表单，随应用和表单的扩大，这将耗尽其有限的内存。
3. Master 节点 CPU 处理速度有限，每秒只能处理数百个请求，并且还要写入部分数据，因此其支持的客户端数量是有限的。
4. 由于 GFS 的数据不总是同步，因此客户端常常无法通过常规手段处理这些数据。
5. Master 节点的切换不是自动的，当 Master 节点宕机，需要数十分钟甚至更长的时间处理。

## Lecture 04 - VMware FT

### 复制

复制（构建多副本）能够处理单台计算机的 fail-stop 问题。复制在错误不独立，或着说副本存在关联的场合无法作用，如软件存在 bug 或（所有）硬件存在缺陷，又或是由于灾害、停电等原因导致的服务器大面积损坏。

复制（副本）的缺点在于硬件成本的成倍增加，因此需要衡量服务的重要性，选择是否配置副本。

### 状态转移和复制状态机

#### 状态转移

试想有一个 Primary 节点和它的 Backup 节点，Primary 节点会定期向 Backup 节点发送最新状态，此即状态转移。当 Primary 宕机，服务能够从 Backup 保存的最新状态启动。为提升效率，可假定只发送变动了的内容。

#### 复制状态机

复制状态机基于这样的事实：每台机器都有着确定的事务处理模式，这时不确定的只有输入量。因此只有在接受外部输入时，Primary 将该输入传递给 Backup 节点，以此来保证状态的一致。

因此我们可以说，状态转移传递**状态**（内存），复制状态机传递**事件**。我们更倾向于使用复制状态机，因为事件通常比状态要小。

### 复制状态机可能存在的一些问题

1. 对多核机器无能为力。由于多核机器上两个核交互的顺序是不确定的，即使传入了相同的指令也不能保证产生相同的结果。在这种情况下，不得不使用状态转移。
2. 由于 Primary 接受指令超前于 Backup，Primary 和 Backup 之间的同步可能出错。因此需要关注同步的频率。
3. 当 Primary 宕机，需要通知客户端去和新的 Primary 通信，而在这一迁移过程中无可避免地会存在切换过程。
4. 当一个副本故障，需要尽快创建一个新的副本补足的情况，由于副本状态不一致，无法使用复制状态机，不得不进行状态转移。这也导致了创建新副本成本很大。

VMware FT 的一大特点就在于其系统级备份。与大多数复制方案采取的应用级备份相比，其或许效率低下，但拥有强大的应用兼容性，在一定条件下，几乎可以正常运行任何软件（毕竟是 V 家虚拟机）。

### VMware FT 工作原理

正如上面所说，VMware FT 的工作基于虚拟机。在两个实体机上运行相同虚拟机，并且在虚拟机中运行相同的操作系统和服务。两个机器由局域网连接，两者互为副本。当客户端向系统以网络数据包的形式发送请求时，虚拟机模拟中断，将请求发送给 Primary；同时，拷贝该数据包，发送给 Backup 所在的虚拟机。Primary 接受信息，并发出返回报文，经由虚拟网卡发给虚拟机，从而发送给客户端。Backup 同样会发送返回报文，但被虚拟机舍弃。

Primary 和 Backup 之间同步的数据流通道被称为 Log Channel。其中从 Primary 发往 Backup 的事件被称为 Log Event/Entry。

当 Primary 宕机，开启容错过程（FT，Fault-Tolerance）。Primary 定时发生定时器中断，每个中断向 Backup 发送一条 Log（心跳），每秒约一百条。当 Backup 无法接收到 Primary 发送的 Log，Backup 就会上线（Go Alive），Backup 的虚拟机使 Backup 自由执行，同时使客户端将后续请求发往该 Backup，该 Backup 就成为了新的 Primary。

与之相对，如果某个 Backup 宕机，Primary 就会停止向其发送事件，抛弃该 Backup。

### 非确定性事件的处理

正如上面所说，Primary 和 Backup 之间的同步基于当前内存状态的一致。而那些不由当前内存状态决定的指令即被称为非确定性事件。它大概有以下几种情况：

1. 客户端输入。客户端发送的数据包包括数据和中断。操作系统会在处理指令的过程中消费中断。如若 Primary 和 Backup 产生中断的时间、在指令流中的位置不同，执行过程就不相同，导致内存状态产生偏差。
2. 怪异指令。怪异指令是指在不同计算机上获得不同结果的指令，如随机数生成器、获取当前时间（如果不同时调用）、获取计算机唯一 ID。
3. 多 CPU 并发。多 CPU 会导致不同的指令调用顺序。系统几乎肯定是在多核机器上运行的，为解决此问题，VMM 暴露给虚拟机的硬件应为单核。
