配置系统时钟
==================================
本节讨论如何配置systemd-timedated系统服务，该服务配置系统时钟和时区。

如果您不记得硬件时钟是否设置为UTC，请通过运行`hwclock --localtime --show`命令查找。这将根据硬件时钟显示当前时间。如果这个时间与你的手表所说的一致，那么硬件时钟被设置为当地时间。如果hwclock的输出不是本地时间，则很可能是UTC时间。通过将时区的适当小时数加上或减去hwclock所示的时间来验证这一点。例如，如果您当前处于MST时区(也称为GMT -0700)，请在当地时间添加七个小时。
systemd-timedated读取`/etc/adjtime`，并根据文件的内容将时钟设置为UTC或本地时间。
/etc/adjtime如果您的硬件时钟设置为本地时间，请使用以下内容 创建文件：
```
cat > /etc/adjtime << "EOF"
0.0 0 0.0
0
LOCAL
EOF
```
```
注意，下面语句需要LFS系统完全启动后才可正常执行
```


如果`/etc/adjtime`在第一次启动时不存在，systemd-timedated将假定硬件时钟设置为UTC并根据该时间调整文件。

如果您的硬件时钟设置为UTC或本地时间， 您还可以使用timedatectl实用程序告诉 systemd-timedated：
```
timedatectl set-local-rtc 1
```
timedatectl也可用于更改系统时间和时区。

要更改您当前的系统时间，请执行
```
timedatectl set-time YYYY-MM-DD HH:MM:SS
```
硬件时钟也将相应更新。

要更改当前时区，请执行以下操作：
```
timedatectl set-timezone TIMEZONE
```
您可以运行以下命令获取可用时区列表：
```
timedatectl list-timezones
```
___________________________________________

## 网络时间同步
从版本213开始，systemd发布了一个名为systemd-timesyncd的守护进程 ，可用于将系统时间与远程NTP服务器进行同步。
该守护进程不是用来替代已建立的NTP守护进程，而是作为客户端唯一的SNTP协议实现，可用于较低级的任务和资源有限的系统。
从systemd版本216开始，系统默认启用systemd-timesyncd守护进程。如果要禁用它，请发出以下命令：
```
systemctl disable systemd-timesyncd
```
该`/etc/systemd/timesyncd.conf`文件可用于更改systemd-timesyncd与之同步的NTP服务器。

请注意，当系统时钟设置为本地时间时,systemd-timesyncd不会更新硬件时钟。