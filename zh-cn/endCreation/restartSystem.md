重新启动系统
==================================

现在已经安装了所有软件，是时候重新启动计算机了。但是，你应该知道一些事情。您在本书中创建的系统非常小，很可能不具备继续前进所需的功能。通过在仍处于当前chroot环境中,使用BLFS书籍中安装一些额外的软件包，您可以让自己处于更好的位置，以便在重新启动到新的LFS安装后继续。以下是一些建议：

* 诸如`Lynx`之类的文本模式浏览器将允许您在一个虚拟终端中轻松查看BLFS书籍，同时在另一个虚拟终端中构建包。

* 该`GPM`包将让你在虚拟终端上完成复制/粘贴操作。

* 如果您处于静态IP配置不符合网络要求的情况，安装 dhcpcd等软件包或 dhcp的客户端部分可能会很有用。

* 安装`sudo`对于以`非root`用户身份构建软件包以及在新系统中轻松安装生成的软件包非常有用。

* 如果要在舒适的GUI环境中从远程系统访问新系统，请安装`openssh`及其先决条件`openssl`。

* 要通过Internet轻松获取文件，请安装`wget`。

如果您的一个或多个磁盘驱动器具有GUID分区表（GPT），则`gptfdisk`或`parted`将非常有用。

最后，此时对以下配置文件的审查也是适当的。

/etc/bashrc
/etc/dircolors
/etc/fstab
/etc/hosts
/etc/inputrc
/etc/profile
/etc/resolv.conf
/etc/vimrc
/root/.bash_profile
/root/.bashrc

现在我们已经说过了，让我们继续第一次启动我们闪亮的新LFS安装！首先退出chroot环境：
```sh
logout
```
然后卸载虚拟文件系统：
```sh
umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys
```
卸载LFS文件系统本身：
```sh
umount -v $LFS
```
如果创建了多个分区，请在卸载主分区之前卸载其他分区，如下所示：
```sh
umount -v $LFS/usr
umount -v $LFS/home
umount -v $LFS
````
现在，重启系统：
```sh
shutdown -r now
```
假设GRUB引导加载程序已按前面所述进行设置，则菜单将设置为 自动引导LFS 8.2。

重启完成后，LFS系统即可使用，可以添加更多软件以满足您的需求。