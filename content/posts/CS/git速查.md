---
title: git速查
created: 2025-05-18 16:49:17
---

## config

```shell
git config --global user.email "your email"
git config --global user.name "your name"
git config --global credential.helper store
git config --global init.defaultBranch main
```

## basic

初始化git：

```shell
git init
```

克隆：

```shell
git clone https://github.com/user/repo.git
```

添加文件到暂存区：

```shell
git add <file>
```

查看日志：

```shell
git log
```


## commit

提交修改：

```shell
git commit -m "some comment"
```

修补上次提交（常用于添加遗漏的文件）：

```shell
git add forgotten_file
git commit --amend
```

从暂存区移除文件（用于已跟踪，但想要添加到.gitignore的情况）：

```shell
git rm --cached <path>
git commit -m "some comment"
```

## remote

添加远程仓库：

```shell
git remote add origin https://github.com/user/repo.git
```

推送提交到远程：

```shell
git push origin main
```

从远程拉取：

```shell
git pull origin main [--merge/--rebase]
```

## submodule

克隆（包括子模块）：

```shell
git clone --recursive https://github.com/user/repo.git
```

添加子模块到目标路径：

```shell
git submodule add https://github.com/user/repo.git ./target_dir/
```

更新子模块：

```shell
git submodule update --recursive --remote --init
```

## undo

尚未提交时执行，丢弃本地所做的更改，回到上次提交之后的状态。

```shell
git checkout . (or filename)
```

执行`git add`，但未提交时执行，可撤回`git add`

```shell
git reset
```

回到上一次提交前的状态，所做的更改不会被丢弃。`HEAD^`表示（第一个）父节点。也可以使用`HEAD^2`指定第二个父节点（如果存在的话）：

```shell
git reset HEAD^
```

回到上一次提交前的状态，所做的更改会被丢弃：

```shell
git reset --hard HEAD^
```

回退前两条提交，并且丢弃所有更改。`~N`表示代数，因此`HEAD~2`表示上面两代的祖先节点：

```shell
git reset --hard HEAD~2
```

回到上一次提交前的状态，但保存工作区和暂存区：

```shell
git reset --soft HEAD^
```

## branch

新建分支：

```shell
git branch <branch>
```

删除分支：

```shell
git branch -d <branch>
git branch -D <branch> # 强制删除
```

移动/重命名分支：

```shell
git branch -m <old> <new>
git branch -M <old> <new> # 强制移动
```

切换分支：

```shell
git checkout <branch>
```

合并分支：

```shell
# 现在在主线分支上
git merge/rebase <branch>
```

合并分支的某个提交：

```shell
# 现在在主线分支上
git log <branch> # 找到待合并提交的哈希
git cherry-pick <hash>
```

## update-index

假定所传入路径文件不会发生更改，即git不再跟踪该文件/文件夹的变更情况：

```shell
git update-index --assume-unchanged <file/folder path>
```

还原：

```shell
git update-index --no-assume-unchanged <file/folder path>
```