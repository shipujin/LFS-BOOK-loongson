编译Lonngson发布的稳定版内核
=========================== 
#获取内核
由于从[Kernel.org](https://www.kernel.org/)下载的内核可能不包含最新的补丁，所以这里使用从[loongson社区下载的稳定版内核](https://github.com/loongson-community/linux-stable)进行接下来的操作。获取方法可以是直接从社区页面上下载Zip压缩包，也可通过git clone命令获取，例如获取4.9分支最新稳定版：
```
# git clone -b rebase-4.9 https://github.com/loongson-community/linux-stable.git 
# cd linux-stable //进入内核目录
```
#配置、编译、安装内核
##配置
获取到内核后进入内核目录，并执行下面这条命令:
```
# make mrproper
```
这条命令作用在于清理原先编译所产生的内容以及配置文件，如果你三第一次编译内核也请先执行这条命令。
执行完上述命令后就可以开始配置内核了，配置内核有多种方式，这里使用官方的配置文件来进行后续操作，接下来将配置文件从
平台相关文件夹中复制到内核目录底下，并改名为`.config`文件
```
# cp -v arch/mips/configs/loongson3_hpcconfig .config
```
将文件复制好后就开始进入内核配置界面对内核进行内部配置了：
```
# make menconfig
```
由于三使用官方默然配置，因此并不需要对配置项进行改动，只需要将`.config`文件加载并保存一遍即可退出配置模式并开始编译内核：


```
# make  //如果需要使用多线程的话需要在make后加入参数"-jN",N为线程数
```
