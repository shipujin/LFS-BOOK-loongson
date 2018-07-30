编译Lonngson发布的稳定版内核
=========================== 
# 获取内核

由于从[Kernel.org](https://www.kernel.org/)下载的内核可能不包含最新的补丁，所以这里使用从[loongson社区Github内核项目](https://github.com/loongson-community/linux-stable)页面上来进行接下来的操作。获取方法可以是直接从链接页面上下载Zip压缩包，也可通过git clone命令获取，例如获取4.9分支最新稳定版（本教程使用的版本是4.9.88）：
```
# git clone -b rebase-4.9 https://github.com/loongson-community/linux-stable.git  
# cd linux-stable #进入内核目录
```

# 配置、编译、安装内核
## 配置
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
# make menuconfig
```
![](https://github.com/TaoistFox/LFS-BOOK-loongson/blob/master/zh-cn/_images/makeKernel_make_menuconfig.png)

由于三使用官方默然配置，因此并不需要对配置项进行改动，只需要将`.config`文件加载并保存一遍即可退出配置模式并开始编译内核

![](https://github.com/TaoistFox/LFS-BOOK-loongson/blob/master/zh-cn/_images/makeKernel_load_config.png)
Load

![](https://github.com/TaoistFox/LFS-BOOK-loongson/blob/master/zh-cn/_images/makeKernel_save_config.png)
Save

![](https://github.com/TaoistFox/LFS-BOOK-loongson/blob/master/zh-cn/_images/makeKernel_save_config_2.png)
Confrimed


需要注意的是这一步骤不能省略，应为从文件夹中复制出来的`.config`文件并不是完整的，此时文件中只存在关键的配置，因此需要在`make menuconfig`命令中加载并再次保存以获得完整的配置文件，如果省略上述步骤将出现出乎意料的结果。

## 编译
处理好内核配置后使用`make`命令即可开始编译内核，如果需要使用多线程的话需要在make后加入参数`-jN`,`N`为线程数：
```
# make
```
编译好内核后需要编译其内核模块，命令为：
```
# make modules
```

这样完整的内核就编译好了，接下来就是将它们放到对应的位置上去

## 安装

首先安装内核模块，命令也很简单
```
 # make modules_install
```
模块将自动安装到相应位置。
接下来则是把与内核相关的几个文件复制到`/boot`目录下
首先是复制内核文件
```
# cp -iv vmlinuz /boot/vmlinuz-4.9.88-lfs-8.2-systemd
```
System.map是内核的符号文件。 它映射内核API中每个函数的函数入口点，以及运行内核的内核数据结构的地址。 在调查内核问题时，它被用作资源。 使用以下命令来安装地图文件：
```
# cp -iv System.map /boot/System.map-4.9.88
```
上面`make menuconfig`步骤进一步生成的内核配置文件`.config`包含刚刚编译的内核的所有配置选择。 保留此文件供将来参考是一个好主意：
```
# cp -iv .config /boot/config-4.15.3
```

安装Linux内核文档：
```
# install -d /usr/share/doc/linux-4.9.88
# cp -r Documentation/* /usr/share/doc/linux-4.9.88
```
需要注意的是，内核源目录中的文件不属于root。 每当一个软件包以root用户的方式解压缩（就像我们在chroot中所做的那样），这些文件就拥有包装者计算机上的用户和组ID。 这通常不是安装任何其他软件包的问题，因为在安装后删除了源代码树。 但是，Linux源代码树通常会保留很长时间。 因为这个原因，无论打包者使用的用户ID都会被分配给机器上的某个人。 那个人就可以拥有对内核源码的写入权限。

# 配置Linux模块加载顺序

大多数情况下，Linux会自动加载模块，但有时需要一些特定的方向。 加载模块modprobe或insmod的程序使用/etc/modprobe.d/usb.conf用于此目的。 这个文件需要被创建，以便如果USB驱动程序（ehci_hcd，ohci_hcd和uhci_hcd）被构建为模块，它们将按照正确的顺序加载; ehci_hcd需要在ohci_hcd和uhci_hcd之前加载，以避免在启动时输出警告。

运行以下命令创建一个新文件/etc/modprobe.d/usb.conf：
```
# install -v -m755 -d /etc/modprobe.d
# cat > /etc/modprobe.d/usb.conf << "EOF"
  # Begin /etc/modprobe.d/usb.conf
  
  install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
  install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
  
  # End /etc/modprobe.d/usb.conf
  EOF
```
到此为止内核已准备就绪，内核如何在开机时启动？它是如何工作的？这个问题将在下一章节中进行说明。
