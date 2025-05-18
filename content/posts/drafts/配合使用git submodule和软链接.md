## 前言

当开发时，经常会有比较复杂的依赖关系。我们的一个库经常会依赖我们写的另一个库，由于两个库之间是独立的，这个时候我们会选择将它作为一个 submodule。

但是，本地进行测试时，如果要对依赖作出修改和测试，就需要频繁对子模块进行提交和拉取，这就会产生问题，也会对本地开发的效率造成影响。

```shell
git submodule add -b kaleido https://github.com/levinion/hierro vendor/hierro
```

```shell
git submodule update --recursive --remote
```

```shell
git update-index --assume-unchanged vendor/hierro
```
