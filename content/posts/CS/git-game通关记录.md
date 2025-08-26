---
title: git-game通关记录
created: 2025-08-26 20:59:07
---
[git-game](https://github.com/git-game/git-game) 是个很有意思的项目，能够锻炼一些常用的 Git 技能。本文简单作下通关记录。

## Level 1

### 问题

Your first task is to checkout the commit whose commit message is the answer to this question:

> When a programmer is born, what is the first thing he/she learns to say?

### 分析

本关需要我们切换到对应问题答案的提交：

> 当一个程序员出生之后，他学会说的第一件事是什么？

```shell
master ❯ git log
commit d851edda3009332dd5d3f8f949a102f279dad809 (HEAD -> master, origin/master, origin/HEAD)                                                                                                          
Author: Henry Garcia <hgarc014@ucr.edu>                                                                                                                                                               
Date:   Wed Jun 10 21:03:04 2015 -0700                                                                                                                                                                
                                                                                                                                                                                                      
    updated README for badge notification                                                                                                                                                             
                                                                                                                                                                                                      
commit 7c8c3ccc2f4bb118a657f1f7a7ab4e163d1b7a30                                                                                                                                                       
Author: Henry Garcia <hgarc014@ucr.edu>                                                                                                                                                               
Date:   Wed Jun 10 20:57:08 2015 -0700                                                                                                                                                                
                                                                                                                                                                                                      
    added level1                                                                                                                                                                                      
                                                                                                                                                                                                      
commit 228389a54073ed1e6ec98e3bfa59039b416efd4d                                                                                                                                                       
Author: Henry Garcia <hgarc014@ucr.edu>                                                                                                                                                               
Date:   Wed Jun 10 20:56:34 2015 -0700

    added welcome screen

commit db99f2d9df4b2288d29a97d2d04a1703b4f3c107
Author: Henry Garcia <hgarc014@ucr.edu>
Date:   Wed Jun 10 20:55:35 2015 -0700

    updated README

commit 640273807f9bac8af03575f82b788663d4b99927
Author: Henry Garcia <hgarc014@ucr.edu>
Date:   Wed Jun 10 20:55:07 2015 -0700

    Hello World!

commit 8cafb7c87b129686da362b14c3f3c750c1fe4bf5 (origin/vector, origin/map, origin/SteveJobs2014, origin/Kevin, origin/KenThompson2014, origin/Daniel, origin/BillGates2014)
Author: Henry Garcia <hgarc014@ucr.edu>
Date:   Sun Nov 30 18:29:35 2014 -0800

    Initial commit
```

当然是 Hello World！所以使用哈希（可以只是开头的一部分）切到对应的提交。

```shell
❯ git checkout 640273807f
Note: switching to '640273807f'.
```

## Level 2

### 问题

We want to get to a branch whose name is the answer to this riddle:
I am a creature that is smaller than man, but many times more in number.
In code, my appearance can be subtle and no matter where I am found, I am unwanted.

What am I?

### 分析

谜题的翻译大概是：

> 我是一种生物，比人类小，但数量多得多。 在代码中，我的出现可能很微妙，无论在哪里被发现，我都不受欢迎。

不需要查看 branch 都知道它是 bug。但我们最好还是看看。

```shell
@64027380 ❯ git branch
* (HEAD detached at 6402738)
  master
```

可以看到此时并没有其他分支，但这只是本地。让我们看看远程分支。

```shell
 @64027380 ❯ git branch -r
  origin/BillGates2014
  origin/Daniel
  origin/HEAD -> origin/master
  origin/Henry
  origin/KenThompson2014
  origin/Kevin
  origin/LinusTorvalds2014
  origin/Mike
  origin/SteveJobs2014
  origin/array
  origin/bug
  origin/code4life
  origin/keyboard
  origin/map
  origin/master
  origin/mouse
  origin/tree
  origin/trees
  origin/vector
```

这下有了，所以切到 bug 分支。

```shell
@64027380 ❯ git checkout origin/bug
Previous HEAD position was 6402738 Hello World!
HEAD is now at 98491ed Update README.md
```

## Level 3

### 问题

Sometimes we like to blame others for introducing bugs in our code.
Think you can find out who introduced a bug into our file cool.cpp?
We think he had something to do with the development of git.
And from what we hear he also made a branch under his name.
Checkout to that branch after you find out who the culprit is.

If you are still confused, this link might [help](http://git-scm.com/docs/git-blame)

### 分析

问题翻译如下：

> 有时候我们喜欢责怪别人，说他们往我们的代码里引入了 bug。
>
> 你能找到是谁在我们的 cool.cpp 文件里引入了一个 bug 吗？ 我们觉得他与 Git 的开发有关系。
>
> 而且我们听说，他还用自己的名字创建了一个分支。
>
> 找到这个罪魁祸首之后，请切换到那个分支。

我们可以看到当前路径下的文件：

```shell
@98491edb ❯ ls
cool.cpp  LICENSE  README.md  remember
```

让我们看一下 `cool.cpp` 的内容：

```cpp
#include <iostream>

using namespace std;

int main()
{
   string mesg = "Hello! Who are you?";
   string input;
   cout << mesg << endl;
   cin >> input;
   cout << "Loops are fun!" << endl;
   while(1);
   string reply = "Well, " + input + ", we hope you are having fun with our git-game!";
   cout << reply << endl; 
}
```

可见，问题出现在 `while(1)`。

然后可以 blame 一下 `cool.cpp`，看看是哪个小傻瓜写了这句代码：

```shell
@98491edb ❯ git blame cool.cpp
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  1) #include <iostream>
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  2) 
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  3) using namespace std;
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  4) 
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  5) int main()
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  6) {
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  7)    string mesg = "Hello! Who are you?";
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  8)    string input;
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800  9)    cout << mesg << endl;
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800 10)    cin >> input;
3922a6d8 (LinusTorvalds2014 2014-12-09 12:37:10 -0800 11)    cout << "Loops are fun!" << endl;
3922a6d8 (LinusTorvalds2014 2014-12-09 12:37:10 -0800 12)    while(1);
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800 13)    string reply = "Well, " + input + ", we hope you are having fun with our git-game!";
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800 14)    cout << reply << endl; 
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800 15) }
ce59bbfd (Henry Garcia      2014-12-08 18:22:35 -0800 16) 
```

```shell
3922a6d8 (LinusTorvalds2014 2014-12-09 12:37:10 -0800 12)    while(1);
```

`LinusTorvalds2014`，哦，是 Linus，那没事了。

然后根据题目指示切换到 Linus 的分支：

```shell
@98491edb ❯ git checkout origin/LinusTorvalds2014
Previous HEAD position was 98491ed Update README.md
HEAD is now at 1254268 added level 5
```

## Level 4

### 题目

Looks like you found the branch of the evil Mastermind.
Things may start to get a little more challenging...

The next clue you are looking for --
is in a file you choose to ignore!

### 分析

不太需要翻译了。我们要找的是一个被忽略的文件，我想这应该是 `.gitignore`。

看下文件内容，啥，我们过关了？

## Level 5

### 题目

上关的 `.gitignore` 内容为：

```.gitignore
# welcome to the ignore file!!

#``Level 5``

# This file is hidden by default, 
# but did you know you have some branches that aren't shown to you,
# when you check the list of branches?
#
# For your next clue...
# Which abstract data type tends to implement sets and maps?? 
# The answer is the same answer to this riddle:
#
#   I am both mother and father.
#   I am seldom still
#   yet I never wander.
#   I never birth nor nurse.
#   
#   What am I?
#
# Afterwards... well, you
# know, checkout to the answer. 

*.rem
a.out
```

### 分析

问题翻译如下：

> 你的下一个线索是……
>
> 哪种抽象数据类型倾向于实现集合（sets）和映射（maps）？
>
> 答案也同样是这个谜语的答案：
>
> 我既是母亲也是父亲。 我很少静止，但我从不游荡。 我从不生育或哺乳。
> 我是什么？
>
> 然后……你懂的，切换到答案。

有点抽象，但这是树。让我们切换到对应树的分支。

```shell
@12542687 ❯ git checkout origin/tree
Previous HEAD position was 1254268 added level 5
HEAD is now at f5c5727 added git merge resource
```

## Level 6

### 问题

Welcome to the "tree" branch.
Looks like good ol' Linus modified the "nextclue_input.cpp" file.
Normally, when ran with the shell script "outputclue.sh", the "nextclue_input.cpp" file would give us the next hint.

Maybe, you should try running the shell script with the "nextclue_input.cpp" file and see what happens...

You can run the script by running the command "./outputclue.sh FILE" .
If you are on Windows, it's okey to use `git-bash` that is installed with [msysgit](https://msysgit.github.io/).

### 分析

翻译如下：

> 欢迎来到 "tree" 分支。
>
> 看来是老朋友林纳斯（Linus）修改了 "nextclue_input.cpp" 文件。
>
> 通常，当和 "outputclue.sh" 这个 shell 脚本一起运行时，"nextclue_input.cpp" 文件会给出我们的下一个提示。
>
> 或许，你应该试着运行这个脚本，并使用 "nextclue_input.cpp" 文件，看看会发生什么……
>
> 你可以使用命令 "./outputclue.sh FILE" 来运行这个脚本。

虽然它让我们运行某个 shell 脚本，但最好在运行前审查下内容：

```shell
#!/bin/bash
if [ -z $1 ]; then 
  echo "well, someone didn't want to run the script with a file...";
  exit;
fi

file=$1
bug=7c85d987a917c2a555d1391426978f05
mesg="Level 7: \n Linus has been here...\nI love messing with these amateur programmers!!\nIf you want some real fun, then you should try resolving a conflict between this branch (tree) and code4life.\nI introduced a little bug that you should fix in the conflict. >:)\nAfter you merge these 2 files you should run the shell script again!!\n\nGood Luck!!!\n\n Hint: https://help.github.com/articles/resolving-a-merge-conflict-from-the-command-line/ "
merges=$(git log --format=%h --merges | head -1)
csum="md5sum"
if [ $(echo "$OSTYPE" | grep darwin) ];then
    csum="md5"
fi

if [ "$file" = "nextclue_input.cpp" ];then 
  if [ ${merges} ]; then 
    while read p; do 
      for w in $p;do 
        if [ `echo $w | $csum | awk '{print $1}'` = $bug ];then 
          echo -e $mesg; 
          exit; 
        fi; 
      done;
    done < $file ;
    echo -e "Well, congratulations!! You fixed my conflict!!\nIf you would like to continue, then you should checkout to the $(echo 90mP8ouQHsNe | tr -d '0-9A-Z') branch!!\n" ;
   else 
     echo -e $mesg; 
     exit;
   fi; 
else 
  echo "Looks like you passed in the wrong file";
fi
```

看上去它没做什么坏事，让我们执行下。很好，通关了。

## Level 7

### 问题

上关的执行结果如下：

```shell
@f5c57273 ❯ ./outputclue.sh nextclue_input.cpp
Level 7: 
 Linus has been here...
I love messing with these amateur programmers!!
If you want some real fun, then you should try resolving a conflict between this branch (tree) and code4life.
I introduced a little bug that you should fix in the conflict. >:)
After you merge these 2 files you should run the shell script again!!

Good Luck!!!

 Hint: https://help.github.com/articles/resolving-a-merge-conflict-from-the-command-line/
```

### 分析

大意是叫我们解决当前分支（tree）和 `code4life` 分支的冲突，Linus 还好心地引入了一个 bug。~~Fuck u Linus~~。

先将 `code4life` 分支 merge 到当前分支上。

```shell
@f5c57273 ❯ git merge origin/code4life
Auto-merging nextclue_input.cpp
CONFLICT (content): Merge conflict in nextclue_input.cpp
Automatic merge failed; fix conflicts and then commit the result.
```

提示有冲突需要解决，这里就用 `vim/nvim` 简单解决下。看到是 `nextclue_input.cpp` 中存在冲突：

```cpp
#include <iostream>

using namespace std;
//Level 9
int main()
{
<<<<<<< HEAD

    cout << "This file was useless, so I made it better..." << endl;
    while(1);
||||||| cf7fc90
    cout << "This file was useless, so I made it better..." << endl;
    while(1);
=======
    cout << "hope you resolved all your conflicts!!" << endl;
>>>>>>> origin/code4life
    return 0;
}
```

因为我设置了 `conflictstyle = diff3`，所以可能看起来有点奇怪。不过无所谓，让我们把它们全删了就行。

PS：上面有个 `//Level 9`，看来将来我们还会用到这个文件。

结果如下：

```cpp
#include <iostream>

using namespace std;
// Level 9
int main() {
  cout << "hope you resolved all your conflicts!!" << endl;
  return 0;
}
```

然后提交。

```shell
~/cloned/git-game @f5c57273 merge ~1 ❯ git add nextclue_input.cpp
~/cloned/git-game @f5c57273 merge +1 ❯ git commit -m "fix merge conflict"
[detached HEAD 7d0f3e2] fix merge conflict
```

再次执行下上面的脚本，输出如下：

```shell
@7d0f3e29 ❯ ./outputclue.sh nextclue_input.cpp
Well, congratulations!! You fixed my conflict!!
If you would like to continue, then you should checkout to the mouse branch!!
```

好的，让我们切到 mouse 分支。

```shell
git checkout origin/mouse                                                                                                                                      20:28:23
Warning: you are leaving 1 commit behind, not connected to
any of your branches:

  7d0f3e2 fix merge conflict

If you want to keep it by creating a new branch, this may be a good time
to do so with:

 git branch <new-branch-name> 7d0f3e2

HEAD is now at 9cc552e added level 8
```

## Level 8

### 问题

Looks like you resolved your conflict and found our branch, congrats!!

Hmm...it seems this branch has a file that was seen before in another branch.
Do you "remember" what it is?
I think this file has something to do with the next clue, but it seems to be very ugly looking.
Maybe if we compare the "diff"erences between this file and the file from before we'll know where to go next...

### 分析

> 嗯……这个分支好像有一个文件，我们在另一个分支见过。 你“记得”它是什么吗？
>
> 我觉得这个文件跟下一个线索有关，但它看起来非常难看。
>
> 也许我们比较一下这个文件和之前那个文件之间的“差异”（diff），就会知道下一步该去哪里了……

题目中所指的文件是 `remember`。幸好我有做笔记，它在 `bug` 分支中出现过。先 diff 一下。

```shell
@9cc552e7 ❯ git diff origin/bug:remember remember
diff --git a/remember b/remember
index 584a931..76bd37c 100644
--- a/remember
+++ b/remember
@@ -2312,7 +2312,7 @@ C7EpVk1Cth5p2tKx0w58i ytUWbvyeysGWv jS4QWZkzlAN2m3EqLffpZiy1XM izQzulpiV Q5eNfJ7
 mrLDUvQK6M 2bREkk3RREZe6Ulawm3SU KHtoKj6jzKwhFYPzhcx1O4Culugp 0UzKqH9CjHM8akQ156fOYAeUUFp McAAI BHuGYzuoqoTSY 7Rby9YLfIMMcysFELGcL1rLD QAo0CaRo22ZfTaf2k iu9KM9ukJ67 EtoBFF9N2Dup5prFQ1 B51i0Kr8 E0 DMNSoaoxG82QQ8moaDFXDP78adKHF zJOCaIjmJQI uAJIAjoPRXXeTY0RrjEPCf 6CPhhKGqtW0KJiZsQk C Wn38v CjzwY4IRYr7W gvlFT6Ng6vmQxLrQEoK
 5NKuMyGGyQum5oQkvP8Am08 OeNWMuTPJIpaBkK LupcmcIO4axxMfp8KnAo m7PFvaY9M5fAn9lfo7Bkm4PBvJJ01 ii2LvkHC8gJ EsHtRTZToBKe pA7ij1m1 bkgGGuQjorQhc0l3bkb7XUoJjII 5ul hxlFoWzySnS M nUlxc5wg2VNIz7lSuuCCG0WL DLeEp7X KsxntcYrDTeV 1psLl YTRf qxrKwPDzSEHbWaxVmXKYpM2dq jV7WELrcHoOQ9D0YQsyQhbtrtp0 Nws3h8dR9ZHAfw0Q2FFvoQd kZFclOzunHHX0k7HWEqS
 57EyTqwnFMX 3CmavTItFa9yjtSIjZ i1VTU06u9rj HShUtnwlqL7ZUZP0i8o7hq U0cS Cr9 sTRitmSvJ7pSDPdd5Emzh xKPGY7mUWTn972NHq HjtdwgQN45QNSZr fyYf 1kBsF5xzcRoyv5K08jlAfoc oG Byz6CAD G4rpwi7HbWlxa0tge moM1Mz9J522wnDDPfOKaj dfL1Mm0G 4k1mQ0P9wAkKiKtLXvj9 fFy2cyfV1c7wzv4uoIQa7fwntk0 rDBPY6sXDNxgAgUIYCwav oVMxzApB5BhLCpvWlIn
-Sn In a branch named: Henry YtrydjKsYqebDoI3h bTINUeV6 pTVY8jnK2re HRwwNy25Ps6 u0YChCo5Jtw N3xkH3G nx aGo6yQTW RVZMsf3xk tBL0sG9GAR HQbyGYdqs i6dx1fyIPGJVciz8Z1NzdrvGE CKgkFauXqfKJmas cDLerWvBTRzUikmP2 0sqk2Xhie2DcIv KtCyYTlNx7WxJp6A2yox3r aJX4r7FpUhgsyGIwc prCCNx46GKVgzaerab3gXS7ieoOf1 Jp
+Sn The next clue is: YtrydjKsYqebDoI3h bTINUeV6 pTVY8jnK2re HRwwNy25Ps6 u0YChCo5Jtw N3xkH3G nx aGo6yQTW RVZMsf3xk tBL0sG9GAR HQbyGYdqs i6dx1fyIPGJVciz8Z1NzdrvGE CKgkFauXqfKJmas cDLerWvBTRzUikmP2 0sqk2Xhie2DcIv KtCyYTlNx7WxJp6A2yox3r aJX4r7FpUhgsyGIwc prCCNx46GKVgzaerab3gXS7ieoOf1 Jp
 n9ec28c7rYYGTF W933ju5 pyH8PXHnKhlwLU0C2akSaPrlpprD spXXhVp6X A6dTg1fBfNBwSvp1sw91Dav67x8f8b Q DAUTWahNriDlArXunXMJ3b489 lcgvI2SViBLrCulZCwsi4kog 4rDVp 90SWto6WkU4Qj gANCojbKr1omMS3hm6p1csqHHdNqy Pw2DzY 0pbPL3KVDW uAUcbE65VsxI 84ZEhEm93tTliegI6tdEPZe H9BV dMk jf1pA12qB8v8 8ep8vfgV9Z a7WqNF5b
 lDSkBLh Sy7L w4X8QJuiL yJ 9KjSn2C12NV 5E7H9S4M7LrV lgxJn1Q8xcnyprQ34g2tC7 Doc36AAsmi58xKa0 kRQntjBdrPfD0QLOj1m ChzWh7JLGBRU Xs446EYE71sHMjtbSsOW4LeVK hzcX391c0Kpyj5bL7sSI5NmE ZrBux2YhJypFB07T03xNWHnLSjXg vbtc3kwd Bkffu aQKZiKBMDgzNBYPnurwpk8 npGXcjZOa9TxIkobUwM8WzApgE pwPwX m7amF juCYRog
 lMrAVrH6 ZzHYozHGN f fE5ficRh2 pMQ6rpXtT49gijgjsO5eykZ9A o 30Tz1Agt5XgV 6odhdhHyYpV8U ZV qc3xnKKPYmjkeJwNGlAtXj f65vcbrsDI7od0E 50EVbGO7iT8Nk2Tilx52wRddM9HeA U8pEHg21Y5CfYjtI5Mnz GZ4lwoqno2Yi13ca2346CG SdoH4FjPUwqidWnZJdDUgqXH2FhpRn lTAPlp8KmiDc2cSEPVMnfzSeSSRC xq57ui lULf1lPpSJ x2 ZgpBp6qzX2v4tI
```

很抽象：

```shell
-Sn In a branch named: Henry YtrydjKsYqebDoI3h bTINUeV6 pTVY8jnK2re HRwwNy25Ps6 u0YChCo5Jtw N3xkH3G nx aGo6yQTW RVZMsf3xk tBL0sG9GAR HQbyGYdqs i6dx1fyIPGJVciz8Z1NzdrvGE CKgkFauXqfKJmas cDLerWvBTRzUikmP2 0sqk2Xhie2DcIv KtCyYTlNx7WxJp6A2yox3r aJX4r7FpUhgsyGIwc prCCNx46GKVgzaerab3gXS7ieoOf1 Jp
+Sn The next clue is: YtrydjKsYqebDoI3h bTINUeV6 pTVY8jnK2re HRwwNy25Ps6 u0YChCo5Jtw N3xkH3G nx aGo6yQTW RVZMsf3xk tBL0sG9GAR HQbyGYdqs i6dx1fyIPGJVciz8Z1NzdrvGE CKgkFauXqfKJmas cDLerWvBTRzUikmP2 0sqk2Xhie2DcIv KtCyYTlNx7WxJp6A2yox3r aJX4r7FpUhgsyGIwc prCCNx46GKVgzaerab3gXS7ieoOf1 Jp
```

但上面出现了一个名字 `Henry`，我猜这就是分支名。让我们切到它。

```shell
@9cc552e7 ❯ git checkout origin/Henry
Previous HEAD position was 9cc552e added level 8
HEAD is now at 51e4359 Update README.md
```

嗯？怎么直接来到了第十关？

## Level 10

### 问题

Welcome!! It looks like you made it to my Branch!!!
Generally you want to refrain from making tags the same name as branches, unless you have a good reason.
The tag is more like the stable release.
While the branch is more like the in progress feature, which will be added soon.

You're almost done!! Excited?? Hope you are! You have one more thing to do!

Now its time to update the master branch, updating is really useful when you fork a repository and your forked repo starts to get behind on commits. The repository to update from is: [https://github.com/drami025/git-game.git](https://github.com/drami025/git-game.git)

Don't cheat!!

Here is a [link](https://help.github.com/articles/configuring-a-remote-for-a-fork/) that explains how to fork a remote repository.

### 分析

不翻译了，大体意思是让我们更新 master 分支。

首先切换到 master 分支。

```shell
@51e4359b ❯ git checkout master
Previous HEAD position was 51e4359 Update README.md
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
```

然后添加一个上游仓库：

```shell
git remote add upstream https://github.com/drami025/git-game.git
```

拉取上游仓库：

```shell
git fetch upstream
remote: Enumerating objects: 38, done.
remote: Counting objects: 100% (14/14), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 38 (delta 11), reused 11 (delta 11), pack-reused 24 (from 1)
Unpacking objects: 100% (38/38), 4.45 KiB | 4.45 MiB/s, done.
From https://github.com/drami025/git-game
 * [new branch]      master     -> upstream/master
```

然后 merge 一下：

```shell
master ❯ git merge upstream/master
Updating d851edd..de79125
Fast-forward
 README.md | 51 +++++++++++++++++++++++++--------------------------
 1 file changed, 25 insertions(+), 26 deletions(-)
```

通关啦：

```shell
Git Game Finish Line
==========

If you did not update the main git-game repository, then we are disappointed in you!!
=======

However, if you did, then great Job!!
You completed our Git Game!


Well you:

- viewed previous commits using "git log"
- traversed to previous commits
- checked out to different branches
- ran "git blame" to see who made changes to a file
- ran the diff command to see differences between branches
- saw what .gitignore included and how it works
- resolved merged conflicts
- saw issues with naming tags and branches the same name
- updated a local repository from a remote repository
 
 Version control systems like git are extremely important tools to learn and use, 
 Especially when collaborating on projects with other developers. 
 It is our hope that you continue to practice your git skills so that you can one day become the ultimate git master!

 Thanks for playing!

 email gitgame.hgarc014@gmail.com with subject: “git-game completion” to get a badge of completion!!
 please note you will not get a response from this email!

 **Please allow up to 2 weeks for the badge to be delivered!!**
 **I try to send badges as soon as possible, Thank You!!**
```
