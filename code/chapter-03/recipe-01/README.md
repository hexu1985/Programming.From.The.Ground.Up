#### 汇编并链接程序

```
$ as exit.s -o exit.o
$ ld exit.o -o exit
```

运行程序并查看退出状态码

```
$ ./exit
$ echo $?
```

让汇编器在可执行文件中包含调试信息：
在as命令中加入`--gstabs`

```
$ as --gstabs exit.s -o exit.o
$ ld exit.o -o exit
```

