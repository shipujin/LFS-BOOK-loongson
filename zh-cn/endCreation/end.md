结束
===============================

做得好！新的LFS系统已安装！我们祝愿您使用闪亮的全新定制Linux系统取得圆满成功。

创建`/etc/os-releasesystemd`所需的文件：
```sh

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="8.2-systemd"
ID=lfs
PRETTY_NAME="Linux From Scratch 8.2-systemd"
VERSION_CODENAME="<your name here>"
EOF

```
建议创建`/etc/lfs-release`文件时与非systemd分支兼容。通过拥有此文件，您可以轻松地(对我们来说，如果您需要在某些时候寻求帮助)找出系统上安装的LFS版本。运行以下命令创建此文件：
```sh

echo 8.2-systemd > /etc/lfs-release

```
创建一个文件以显示新系统相对于Linux标准库（LSB）的状态也是一个好主意。要创建此文件，请运行：
```sh

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="8.2-systemd"
DISTRIB_CODENAME="<your name here>"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

```
务必为“DISTRIB_CODENAME”字段进行某种自定义，以使系统与众不同。