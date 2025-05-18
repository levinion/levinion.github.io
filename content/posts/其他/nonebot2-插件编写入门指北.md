---
title: "Nonebot2-插件编写入门指北"
created: 2022-11-29 13:37:42
---
## 指北请注意

nonebot2 是一个由 python 编写的跨平台异步机器人框架，对那些想拥有一个自己的机器人的人来说，nonebot2 是一个理想的选择。nonebot2 学习门槛不高——你所需要的只是一些 python 基础。如果你没有学过 python，但有其他编程语言基础，那也没有关系；因为我也将近一年多没有接触过 python 编程，和初学者没有什么两样，因此如果代码稀烂的话还请多多谅解。

写这篇文章的部分原因是因为官网的教程过于简约（？）或零碎，而且少有代码范例，对想要深入实践编写插件的人造成了一定困难；另一部分也是作为这几天编写插件经验的总结。本文风格偏重实践，并不打算事无巨细地讲清楚内在原理；这其实是我知识不足的原因。因此如果想要同时搞清楚理论的话，我会尽量给出参考的链接。如果正在阅读这篇文章的你能够知道“我写这篇文章的同时也是在和你一同学习”的话，那可就太好了。

在正文开始前，你应当已经做到了以下几点：

- [ ] 已经配置好 nonebot2 开发环境
- [ ] 具备一定的 python 基础（如果有其他编程语言经验，至少具备查阅资料的能力）
- [ ] 积极动手实践

<em style="color:pink">> 这篇文章的大体思路如下：</em>

1. Hello World
2. 以我自己编写的插件 “sumi” 为例，你能够学会：

- 对戳一戳事件的回应
- 命令参数
- 自定义规则
- 读取环境配置
- JSON 保存和读取数据
- 发送和下载图片到本地（没错，就是偷图功能哒！）

行了，废话不多说，让我们开始吧。

## 1 Hello World

正如每种语言都从输出 "hello world" 开始那样，我们的第一个插件尝试让 bot 发送一条 "hello world" 信息给用户。

### 1.1 准备 - 项目文件结构

在开始正式编写插件之前，我们先了解一下插件编写的文件结构。

```
.  
├── bot.py  
├── docker-compose.yml  
├── Dockerfile  
├── firststep  
│   └── plugins  
├── pyproject.toml  
└── README.md
```

这是刚刚创建项目时所具有的最简文件结构。我们所编写的插件应当放在 `{项目名}/plugins` 文件夹下。 `bot.py` 是程序的入口，负责插件的调用。

```
.  
└── plugins  
   └── hello_world  
       └── __init__.py
```

首先在 `plugins` 目录下创建名为 `hello_world` 的文件夹，此即插件名称；插件主程序一般命名为 `__init__.py` 。

> 如果你想要将插件发布到商店，按照规范，插件名称应当以 `nonebot-plugin-` 或 `nonebot_plugin_` 开头，本文为练习方便起见，不遵循此规定。

### 1.2 始动 - hello world 程序

```python
from nonebot import on_command

hello_world = on_command("hi")
@hello_world.handle()
async def _():
    await hello_world.send("hello world")
```

短短六行代码即可完成整个工作流（请忽略中间的那个空行喵）：

1. 响应器接收到用户发送的指令 “hi”；
2. 通过 `handle` 装饰器进入到插件的运行流程；
3. 然后异步函数向用户发送信息。

具体的响应器类型请参考官网内容—— [定义事件响应器](https://nb2.baka.icu/docs/tutorial/plugin/create-matcher)。

### 1.3 进阶 - 由 hello world 过渡到实用插件

通过以上代码，我们已经实现 bot 向用户发送信息。如果加上事件处理，就能够实现更多实用功能。

```python
import ...

hello_world = on_command(...)
@hello_world.handle()
async def _():
    # 返回数据的请求api
    api=...
    # 由api请求数据
    ...
    data=...
    # 处理得到数据，生成发送用户的信息
    ...
    message=...
    await hello_world.send(message)
```

## 2 正式开始？——其实已经结束了

### 2.1 第一步 - poke 行为触发

```python
from nonebot.adapters.onebot.v11 import MessageSegment，PokeNotifyEvent
from nonebot import on_notice

def _poke_check(event:PokeNotifyEvent):
    return event.target_id==event.self_id

poke=on_notice(rule=_poke_check,priority=5,block=True)
@poke.handle()
async def _(event:PokeNotifyEvent):
    user_id=event.get_user_id()
    await poke.finish(MessageSegment.at(user_id)+Message("hi")
```

这是一段检测 poke 行为并进行回复的简易程序，下面我们将对其进行讲解。

首先我们定义了一个用以检验 poke 行为的自定义规则。`PokeNotifyEvent` 是一个 Poke 事件，当该事件作用的对象为机器人本身时，进入响应器的作用流程。

`on_notice()` 注册了一个消息事件响应器。自定义规则通过 rule 传递给响应器，`priority` 指定响应器的作用优先级，`block=True` 时不再响应优先级更低的事件。

`MessageSegment` 是一个非常好用的工具。在 nonebot 中，我们想要发送图片，或@某人等特殊信息，通常使用 CQ 码。`MessageSegment` 对 CQ 码进行包装，使其更加容易编写。此处我们使用 `MessageSegment.at()` 函数，实现了@某人的效果。

当我们要实现一个动作时，往往需要提前告知动作作用的对象。`event.get_user_id()` 返回 string 格式的用户 QQ 号。

`MessageSegment` 返回一个 `Message` 对象，能够和其他 `Message` 对象相加，合并成一个消息列表。因此最后发送给用户的信息应当是：“@用户名 hi”。

### 2.2 第二步 - 叫我主人大人！

有时我们需要从用户发送的消息中抽取有用的信息，并对其进行处理或存储。这通常使用 `CommandArg` 来实现。

```python
call_me=on_command("叫我",rule=to_me()& Rule(is_super_user),priority=8)
@call_me.handle()
async def _(event:Event,args:Message=CommandArg()):
    arg:List[str]=args.extract_plain_text().strip().split()
    user_id=event.get_user_id()
    if len(arg)!=1:
        await call_me.finish(MessageSegment.at(user_id)+Message("没有那样的称呼啦！"))
    else:
        oyobi=arg[0]
        config_file=f"{os.path.dirname(__file__)}/config.json"
        with open(config_file,"r") as file:
            try:
                content=json.load(file)
            except:
                content={}
        content.setdefault(user_id,{}).setdefault("oyobi",oyobi)
        with open(config_file,"w") as file:
            json.dump(content,file,ensure_ascii=False)
        await call_me.finish(MessageSegment.at(user_id)+Message(f"好的哦，{oyobi}!"))

```

CommandArg 获取的消息是一个 Message 对象，需要使用 extract. `plain_text()` 函数返回一个消息字符串。当然你也可以使用 split 方法对这个字符串进行切割，从而返回一个 string 列表。我在上面的示例中就是这样做的。我通过 `if else` 语句强制规定该响应器只能接受一个参数。

`oyobi` 变量成功保存了接受到的命令参数，接着就是 python 中基本的文件操作。这里你需要掌握的是 JSON 文件的操作。JSON 格式文件常用于 nonebot 中的数据保存。由于不需要建立数据库，只需要操作文件，所以方便快捷。对 JSON 的操作一般包括增删改查，流程大都是通过调用 `json.load()` 和 `json.dump()` 两个函数。`json.load()` 函数用以读取 JSON 格式信息并转化为字典或列表格式的变量。`json.dump()` 函数将 python 中的数据格式，如字典或列表转化为 JSON 格式数据并写入文件中。在要保存的数据中包括 cjk 字符（中文或日文等）的情况下，建议将 `json.dump()` 函数中的 `ensure_ascii` 参数置为 `False`，否则 cjk 字符将被保存为 ascii 码导致阅读困难。

学会 JSON 的操作，你就可以写下一个响应器，让机器人叫你你喜欢的名字了（<s>比如 ご 主人様之类</s>）。

### 2.3 第三步 - 你到底是不是我的主人？

说是例子，其实更恰当地来讲不过是工具函数罢了。判断是否超管在实现某些功能时很有必要，比如对你示爱，对其他人冷眼以对的<s>超级棒的</s>机器人。自定义规则适用于响应器中事件的判断，如果你想要对响应器是否执行进行判断（如果不符合，不进入响应器），可以使用 `nonebot.rule` 中封装好的规则，如 `to_me` 等，或 `nonebot.permission` 中的封装好的权限，如 `SUPERUSER`。

```python
import nonebot

def is_super_user(event:Event):
    """
    判断当前交互对象是否超级管理员
    """
    return event.get_user_id() in nonebot.get_driver().config.superusers

def is_not_super_user(event:Event):
    """
    判断当前交互对象是否不是超级管理员
    """
    return event.get_user_id() not in nonebot.get_driver().config.superusers
```

全局配置文件由工程文件夹下的 `.env` 指定，通常为 `.env.dev` 或 `.env.prod`。事实上，读取配置在官网上给出了至少三种方法，我这里只给出一种，其他请自行上官网查看。你可以通过 `nonebot.get_driver().config`，从驱动器中获取配置文件。值得注意的是，配置文件中的 key 不区分大小写（事实上，一般都用大写），而插件中只能使用小写。

```python
def _poke_check(event:PokeNotifyEvent):
    return event.target_id==event.self_id

poke=on_notice(rule=_poke_check,priority=5)
@poke.handle()
async def _(event:PokeNotifyEvent):
    user_id=event.get_user_id()
    if is_super_user(event):
        mes=MessageSegment.image(f"file:///{img}")+MessageSegment.at(user_id)+Message("贴贴～")
        await poke.finish(mes)
    else:
        await poke.finish(MessageSegment.at(user_id)+Message("滚"))
```

<s>稍稍修改第一个程序即可收获秀恩爱机器人一名，以及所有尝试戳机器人的人的无情谩骂（别问我怎么知道的）</s>

### 2.4 第四步 - 好图，我的了！

```python
# 图片收集
def _img_check(event: Event):
    if is_super_user(event):
        return str(event.get_message()).startswith("[CQ:image") and to_me()
    else:
        return str(event.get_message()).startswith("[CQ:image") and prepare(60)

collect=on_message(rule=_img_check,priority=100,block=True)
@collect.handle()
async def _collect(event: Event):
    try:
        mes=event.get_message()
        pic=str(mes)
        url=re.search(r"http.*]",pic).group().removesuffix("]")
        uuid_str = uuid.uuid4().hex
        r=httpx.get(url)
        img=f"{img_dir_path}/default/{uuid_str}.jpg"
        with open(img,"wb") as file:
            file.write(r.content)
        await collect.finish("好图，我的了")
    except:
        logger.error("糟糕，没能抓到图(QAQ)")
```

机器人的自主学习使我们梦寐以求的。偷图虽然离自主学习还很遥远（<s>其实根本八竿子打不着</s>），但偷图依然是一项实用的功能。

现在你已经掌握了编写插件所具有的基本知识，因此我想到了这步，只是提示一下思路就已经足够了。

正如我们前面所说，cq-http 中一些复杂消息类型，如@或图片等均是通过 CQ 码实现的。因此我们接收到的图片应当是类似 `[CQ:image,...,url=http://xxx.com/xxx.jpg]` 的格式，因此我们可以使用一些方式，如正则或 JSON 的方式获取消息中的 url，并且利用 request 或着 httpx 将 url 的图片下载到本地。

### 2.5 第五步 - 随机回复

```python
# 随机回复
def _reply_check():
    return prepare(10)

reply=on_message(rule=_reply_check,priority=130)
@reply.handle()
async def _reply():
    try:
        img_default_list=os.listdir(f"{img_dir_path}/default")
        img=f"{img_dir_path}/default/{random.choice(img_default_list)}"
        await reply.send(MessageSegment.image(f"file:///{img}"))
    except:
        logger.error("reply不小心出错了诶嘿")
```

随机回复一般用于让机器人群聊中加入聊天话题，此功能被证明干扰性较强，因此慎用。不知你有没有注意到，在上个程序中和这个程序中都用到了 `prepare()` 函数。`prepare` 函数是我定义的一个工具函数，用以确定触发概率。其定义如下：

```python
def prepare(s:int=10):
    """
    概率函数,参数 s 决定概率是 s%
    """
    return random.random()*100 < s
```

给出了这个函数，结合你学到的知识，你应该能够轻松看懂这个程序，因此就程序不做讲解了。与之相比，我想要说的是干扰性的问题。我们通常难以对概率有一个清楚的认知，要知道，一般抽卡手游的概率可是 2% 左右，即使是 10% 的概率也是天文数字。在一个活跃的群里，10% 的概率意味着每隔几秒机器人就会发一次言；但是在一个冷门的群里，大家一天只发一两句话，那么机器人几乎不可能发言。在后一种情况下，这个功能其实可有可无，也不存在干扰的问题；但在前者，我们就需要降低概率，甚至添加冷却时间以防止连续触发。
