编译Lonngson发布的稳定版内核
=========================== 
#获取内核
由于从[Kernel.org](https://www.kernel.org/)下载的内核可能不包含最新的补丁，所以这里使用从[loongson社区下载的稳定版内核](https://github.com/loongson-community/linux-stable)进行接下来的操作。获取方法可以是直接从社区页面上下载Zip压缩包，也可通过git clone命令获取，例如获取4.9分支最新稳定版：
```
git clone -b rebase-4.9 https://github.com/loongson-community/linux-stable.git 
```
#配置、编译、安装内核
##配置
获取到内核后进入内核目录，并执行下面这条命令:
```
make mrproper
```
这条命令作用在于清理原先编译所产生的内容以及配置文件，如果你三第一次编译内核也请先执行这条命令。
执行完上述命令后就可以开始配置内核了，配置内核有多种方式，这里使用官方的配置文件来进行后续操作
