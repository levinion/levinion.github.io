---
title: git-game-v2
created: 2025-08-26 12:16:42
---
## Level 1

### 问题

The first level demonstrates the power of `git ls-files`.

Running `git ls-files` lists all the files in the current commit.

Checkout the [documentation](http://git-scm.com/docs/git-ls-files) for more details.

Can you figure out why running the standard Unix `ls` doesn't list all the files in the current commit?

Your task for this level is to use `git ls-files` to count the total number of *lines* in this commit.

In other words, count the number of lines in each file, then add all these numbers together to get the total.

To advance to level 2 you need to checkout the branch named after the total. 
So if the total number is 780 then you would run:

```
$ git checkout 780
```

*Hint:* 
You will need to combine `git ls-files` with other Unix utilities using pipes. 
[This stackoverflow question](http://stackoverflow.com/questions/4822471/count-number-of-lines-in-a-git-r) has a useful example that will get you started.


### 分析

题目大意是计算下`git ls-files`的行数，这可以通过`wc`实现。

```shell
master ❯ git ls-files | xargs wc -l | grep total
6865 tota
```

所以切换到`6865`这个分支：

```shell
master ❯ git checkout 6865
branch '6865' set up to track 'origin/6865'.
Switched to a new branch '6865'
```

但是惊喜地发现：

```txt
#git-game-v2

Welcome, this is not the branch you are looking for.
```

找了下仓库，发现了这个 issue：[# Level 1 challenge correct branch not updated with latest commit.](https://github.com/git-game/git-game-v2/issues/8)。解决方案是从结果中减去4行。

```shell
master ❯ git checkout 6861
branch '6861' set up to track 'origin/6861'.
Switched to a new branch '6861'
```

终于进入第二关。

## Level 2

### 问题

You're now in level 2! The purpose of this level is to *show* you the power of `git show`. 
Running this command shows one or more objects ([blobs](http://gitready.com/beginner/2009/02/17/how-git-stores-your-data.html),
[trees](http://365git.tumblr.com/post/492744368/git-objects-the-tree),
[tags](http://git-scm.com/docs/git-tag), and [commits](http://gitref.org/basic/)).
Look at the [documentation](http://git-scm.com/docs/git-show) for more details.

Your task for this level is to find the answer to the riddle below:

> I have many keys but useless locks. I have space but no room. You can enter and also escape. What am I?

The answer to this riddle is in one of the commit messages.
Use `git log` to find the commit hash corresponding to the commit message.
Then run `git show` on that hash.
This will bring up instructions on how to proceed to level3.

*Hint:* if you're stuck, look at this [stack overflow question](http://stackoverflow.com/questions/7663451/view-a-specific-git-commit).

### 分析
