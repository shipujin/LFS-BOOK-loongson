最后的系统配置
=====================
### 通用网络配置

#### 本节仅适用于配置网卡的情况。
________________________________

从209版开始，systemd发布了一个名为systemd-networkd的网络配置守护进程，可用于基本网络配置。 此外，从版本213开始，DNS名称解析可以通过systemd解析来代替静态`/etc/resolv.conf`文件来处理。 这两项服务都默认启用。

systemd-networkd(和systemd-resolved)的配置文件可以放在`/usr/lib/systemd/network`或`/etc/systemd/network`中。`/etc/systemd/network`中的文件比`/usr/lib/systemd/network`中的文件具有更高的优先级.有三种类型的配置文件：`.link`，`.netdev`和`.network`文件。 有关这些配置文件的详细说明和示例内容，请参阅systemd-link(5)，systemd-netdev(5)和systemd-network(5)手册页。

________________________________

### 网络设备命名

Udev通常根据系统物理特性(如enp2s1)分配网卡接口名称。如果您不确定您的接口名称是什么，那么您可以在引导系统后始终运行`ip link`。
对于大多数系统，每种连接只有一个网络接口。 例如，有线连接的经典接口名称是`eth0`。无线连接通常具有名称`wifi0`或`wlan0`。
如果您更喜欢使用经典或自定义的网络接口名称，那么有三种方法可以实现这一点：

为默认策略掩盖udev的.link文件：
```
ln -s /dev/null /etc/systemd/network/99-default.link

```

创建一个手动命名方案，例如通过命名接口，如“internet0”，“dmz0”或“lan0”。为此，请在`/etc/systemd/network/`中创建.link文件，为一个，部分或全部接口选择明确的名称或更好的命名方案。例如：

```
cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Change the MAC address as appropriate for your network device
MACAddress=12:34:45:78:90:AB

[Link]
Name=ether0
EOF

```

有关更多信息，请参见手册页systemd.link(5)。
*	在`/boot/grub/grub.cfg`中，在内核命令行中传递选项`net.ifnames = 0`。

_________________________________________________

### 静态IP配置

以下命令为静态IP设置(使用systemd-networkd和systemd-resolved)创建基本配置文件：
```
cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
Domains=<Your Domain Name>
EOF
```
如果您有多个DNS服务器，则可以添加多个DNS条目。如果您打算使用静态`/etc/resolv.conf`文件，请不要包含DNS或Domains条目。

___________________________________________________

### 配置DHCP

以下命令为IPv4的DHCP设置创建基本配置文件：

```
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF

```
__________________________________________________

#### 创建/etc/resolv.conf文件

如果系统要连接到Internet，则需要一些域名服务（DNS）名称解析方法来将Internet域名解析为IP地址，反之亦然。这最好通过将ISP服务器或网络管理员提供的DNS服务器的IP地址放入/etc/resolv.conf。

##### systemd-resolved配置
>       注意
>       如果使用其他方法来配置网络接口（例如：ppp，网络管理器等），或者使用任何类型的本地解析器（例如：bind，dnsmasq等）或任何其他生成/etc/resolv.conf （ex ：resolvconf），则不应使用systemd解析的服务。

>当使用systemd-resolved解析 DNS配置时，它会创建该文件/run/systemd/resolve/resolv.conf。创建一个符号链接/etc来使用生成的文件：
>
>    	ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf


___________________________________________________

#### 静态resolv.conf配置

如果需要静态`/etc/resolv.conf`，请通过运行以下命令来创建它：

```
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF

```
该domain声明可以省略或用search声明代替。有关更多详细信息，请参见resolv.conf的手册页。
替换`<IP address of the nameserver>`为最适合安装的DNS的IP地址。通常会有多个条目（需求要求备用服务器具备后备功能）。如果您只需要或需要一台DNS服务器，请从文件中删除第二个名称服务器行。IP地址也可能是本地网络上的路由器。

>       注意!
>       该谷歌公共IPv4的DNS地址是8.8.8.8与8.8.4.4IPv4的，并且IPv6使用2001:4860:4860::8888和2001:4860:4860::8844。

________________________________________________________

#### 配置系统主机名

在引导过程中，该文件`/etc/hostname`用于建立系统的主机名。

>创建/etc/hostname文件并通过运行输入主机名：

>       echo "<lfs>" > /etc/hostname

`<lfs>`需要用给予计算机的名称来替换。请勿在此处输入完全限定的域名(FQDN)。这些信息放在`/etc/hosts`文件中。

________________________________________________________
### 自定义/etc/hosts文件

>决定一个完全合格的域名（FQDN），以及可能在/etc/hosts 文件中使用的别名。如果使用静态地址，您还需要决定IP地址。主机文件条目的语法是：

>       IP_address myhost.example.org aliases
>除非计算机在互联网上可见（即有一个已注册的域和一个有效的已分配IP地址块 - 大多数用户没有），请确保该IP地址位于专用网络IP地址范围内。有效范围是：

>       Private Network Address Range      Normal Prefix
>       10.0.0.1 - 10.255.255.254           8
>       172.x.0.1 - 172.x.255.254           16
>       192.168.y.1 - 192.168.y.254         24
`x`可以是16-31范围内的任何数字。y可以是0-255范围内的任何数字。

有效的私有IP地址可能是192.168.1.1。此IP的有效FQDN可以是lfs.example.org。

即使不使用网卡，仍然需要有效的FQDN。这对于某些程序正常运行是必需的。

如果使用DHCP，DHCPv6，IPv6自动配置，或者如果网卡不打算配置，请`/etc/hosts`通过运行以下命令来创建该文件：
```
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost
127.0.1.1 <FQDN> <HOSTNAME>
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
```
:: 1项是127.0.0.1的IPv6对应项，代表IPv6回送接口。127.0.1.1是专门为FQDN保留的环回条目。

如果使用静态地址，请/etc/hosts通过运行此命令来创建该文件：
```
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost
127.0.1.1 <FQDN> <HOSTNAME>
<192.168.0.2> <FQDN> <HOSTNAME> [alias1] [alias2] ...
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
```
`<192.168.0.2>`，` <FQDN>`和 `<HOSTNAME>`的值需要改变用于特定用途或要求（如果由网络/系统管理员分配一个IP地址和机器将被连接到现有的网络）。可选的别名可以省略。最后的系统配置
______________________________________


7.3 设备和模块处理概述
========================================
在第6章中，我们在systemd构建时安装了Udev软件包。在讨论如何工作的细节之前，先了解以前处理设备的方法的简要历史记录。

传统上，Linux系统通常使用静态设备创建方法，因此/dev无论相应的硬件设备是否真实存在，都会创建很多设备节点 （有时几千个节点）。这通常是通过一个MAKEDEV脚本完成的，该脚本包含许多对mknod程序的调用，以及对于世界上可能存在的每种可能设备的相关主要和次要设备编号。

使用Udev方法，只有内核检测到的那些设备才会为它们创建设备节点。因为每次系统引导时都会创建这些设备节点，所以它们将存储在 devtmpfs文件系统（完全驻留在系统内存中的虚拟文件系统）中。设备节点不需要太多空间，所以使用的内存可以忽略不计。

##7.3.1 历史
2000年2月，一个新的文件系统devfs被合并到2.3.46内核中，并在2.4系列稳定内核期间可用。虽然它出现在内核源码本身中，但这种动态创建设备的方法从未得到核心内核开发人员的强大支持。
这种方法的主要问题在于devfs它处理设备检测，创建和命名的方式。后一个问题，即设备节点​​命名，可能是最关键的。一般认为，如果允许设备名称是可配置的，那么设备命名策略应该由系统管理员决定，而不是由任何特定的开发人员强加给他们。该devfs文件系统还存在竞争条件是在其设计中固有的，无法固定而大幅修改内核遭遇。它被标记为很长一段时间 - 由于缺乏维护 - 最终在2006年6月从内核中删除。

随着不稳定2.5内核树的发展，后来发布为2.6系列稳定内核，一个新的虚拟文件系统被调用sysfs。其工作sysfs就是将系统硬件配置的视图导出到用户空间进程。通过这个用户空间可见的表示，开发用户空间替换的可能性devfs变得更加现实。
__________________________________________________

### 7.3.2 Udev实现
#### 7.3.2.1 SYSFS
该sysfs文件系统被简要提及。有人可能会想知道如何sysfs知道系统中存在的设备以及应该使用哪些设备编号。当内核sysfs检测到它们时，已经编译到内核中的驱动程序直接在内部注册它们的对象(内部为devtmpfs)。对于编译为模块的驱动程序，当模块加载时会进行注册。一旦sysfs文件系统被挂载(在/sys上)，驱动程序注册的数据sysfs可用于用户空间进程和udevd进行处理(包括对设备节点的修改)。

####7.3.2.2 设备节点创建
设备文件由内核由devtmpfs文件系统创建。任何希望注册设备节点devtmpfs的驱动程序都会通过(通过驱动程序核心)来完成。当devtmpfs安装实例时`/dev`，设备节点最初将使用固定的名称，权限和所有者创建。
不久之后，内核会发送一条消息给udevd。基于在内的文件中指定的规则`/etc/udev/rules.d`，`/lib/udev/rules.d`和`/run/udev/rules.d`目录，udevd会将创建的符号链接附加到该设备节点，或改变它的权限，拥有者，或修改内部的udevd该对象数据库条目(名称)。
这三个目录中的规则被编号，所有三个目录合并在一起。如果udevd无法找到它正在创建的设备的规则，则会在devtmpfs 最初使用的设备上留下权限和所有权。

####7.3.2.3 模块加载
作为模块编译的设备驱动程序可能会内置别名。别名在modinfo程序的输出中可见，并且通常与模块支持的设备的总线特定标识符相关。例如，snd-fm801驱动程序支持具有供应商ID 0x1319和设备ID 0x0801的PCI设备，并具有“ pci：v00001319d00000801sv * sd * bc04sc01i * ”的别名。对于大多数设备，总线驱动程序会导出将通过设备处理设备的驱动程序的别名sysfs。例如，该/sys/bus/pci/devices/0000:00:0d.0/modalias文件可能包含字符串“ pci：v00001319d00000801sv00001319sd00001319bc04sc01i00“。Udev提供的默认规则将导致udevd使用uevent环境变量的内容(应该与sysfs中的文件的内容相同)调用/sbin/modprobe，从而加载所有其别名与此字符串匹配的模块通配符扩展后的MODALIASmodalias
在这个例子中，这意味着，除了snd-fm801之外，过时的(和不需要的)forte驱动程序如果可用则将被加载。请参阅下文，了解如何防止加载不需要的驱动程序。
内核本身也能够根据需要加载用于网络协议，文件系统和NLS支持的模块。


#### 7.3.2.4 处理热插拔/动态设备
当您插入设备时，例如通用串行总线（USB）MP3播放器，内核会识别出设备现在已连接并生成一个uevent。如上所述，该事件随后由udevd处理 。
_________________________________________________________________
### 7.3.3 加载模块和创建设备的问题
自动创建设备节点时有几个可能的问题。

#### 7.3.3.1 内核模块不会自动加载
如果Udev具有总线专用别名，并且总线驱动程序正确导出必要的别名，则Udev将只加载模块sysfs。在其他情况下，应该通过其他方式安排模块加载。使用Linux-4.15.3，Udev可以为INPUT，IDE，PCI，USB，SCSI，SERIO和FireWire设备加载正确编写的驱动程序。
要确定您需要的设备驱动程序是否具有对Udev的必要支持，请以模块名称作为参数运行modinfo。现在尝试查找设备目录下，/sys/bus并检查是否有一个modalias文件。
如果modalias文件存在sysfs，驱动程序支持该设备并可以直接与它通话，但没有别名，这是驱动程序中的错误。在没有Udev帮助的情况下加载驱动程序，并期待稍后解决问题。
如果modalias在相关目录下没有文件/sys/bus，这意味着内核开发者还没有为这种总线类型添加modalias支持。在Linux-4.15.3中，ISA总线就是这种情况。预计此问题将在以后的内核版本中修复。
Udev不打算加载 诸如snd-pcm-oss之类的“包装器”驱动程序，以及诸如循环之类的非硬件驱动程序。

#### 7.3.3.2 内核模块不会自动加载，Udev不会加载它

如果“包装器”模块仅增强某些其他模块提供的功能(例如snd-pcm-oss通过使声卡可用于OSS应用程序来增强snd-pcm的功能)，则配置modprobe以在Udev加载之后加载包装器包装的模块。为此，请将“softdep”行添加到相应的文件中。例如:
```
/etc/modprobe.d/<filename>.conf
softdep snd-pcm post: snd-pcm-oss
```

请注意，“softdep”命令也允许 pre:依赖关系，或两者的混合物pre:和post:。有关“softdep 语法和功能的modprobe.d(5)更多信息，请参见手册页。

如果所讨论的模块不是包装器并且本身很有用，请配置模块 bootscript以在系统引导时加载此模块。为此，请/etc/sysconfig/modules在单独的行中将模块名称添加到文件中。这也适用于包装模块，但在这种情况下是不理想的。

#### 7.3.3.3 Udev加载一些不需要的模块
要么不建立模块，要么/etc/modprobe.d/blacklist.conf像下面例子中的forte模块一样将它黑名单列入文件中：
```
blacklist forte
```

列入黑名单的模块仍可以使用明确的modprobe 命令手动加载。

#### 7.3.3.4 Udev错误地创建了一个设备，或者造成了错误的符号链接
如果规则意外与设备匹配，通常会发生这种情况。例如，编写不好的规则可以按照供应商的要求(根据需要)和相应的SCSI通用设备(不正确)匹配。在udevadm info命令的帮助下查找违规规则并使其更具体。

#### 7.3.3.5 Udev统治不可靠
这可能是前一个问题的另一种表现。如果没有，并且您的规则使用sysfs属性，则可能是内核计时问题，需要在以后的内核中修复。现在，您可以通过创建一个等待使用的sysfs属性并将其附加到/etc/udev/rules.d/10-wait_for_sysfs.rules文件(如果该文件不存在，则创建该文件)来解决该问题。如果你这样做，请通知LFS发展名单，这对你有所帮助。

#### 7.3.3.6 Udev不创建设备
更多的文本假定驱动程序是静态构建到内核中的，或者已经作为模块加载，并且您已经检查过Udev没有创建错误的设备。

如果内核驱动程序不将数据导出到Udev，则无需创建设备节点的信息sysfs。这在内核树之外的第三方驱动程序中最为常见。/lib/udev/devices使用适当的主/次编号创建一个静态设备节点(请参阅devices.txt内核文档中的文件或由第三方驱动程序供应商提供的文档)。静态设备节点将被复制到/dev由udev的。

#### 7.3.3.7 设备命名顺序在重启后随机更改
这是由于Udev在设计上处理事件并且以并行的方式加载模块，因此以不可预知的顺序。这永远不会“ 固定 ”。您不应该依赖内核设备名称的稳定性。相反，应根据设备的某些稳定属性(例如序列号或Udev安装的各种*_id实用程序的输出)创建自己的规则，以便使用稳定的名称创建符号链接。有关示例，请参见第7.4节“管理设备”和第7.2节“常规网络配置”。
_________________________________________________________________________
### 7.3.4 有用的阅读
以下网站提供了其他有用的文档：
用户空间实现devfs http://www.kroah.com/linux/talks/ols_2003_udev_paper/Reprint-Kroah-Hartman-OLS2003.pdf
该sysfs文件系统 http://www.kernel.org/pub/linux/kernel/people/mochel/doc/papers/ols-2005/mochel.pdf



### 7.4 管理设备
#### 7.4.1 处理重复的设备
如第7.3节“设备和模块处理概述”所述，具有相同功能的设备出现的顺序/dev基本上是随机的。例如，如果您有USB网络摄像头和电视调谐器，有时会/dev/video0指向相机并/dev/video1指向调谐器，有时在重新启动后，顺序会变为相反的顺序。对于除声卡和网卡之外的所有类别的硬件，这可以通过为自定义持久性符号链接创建Udev规则来解决。第7.2节“通用网络配置”中分别介绍了网卡的情况，声卡配置可在 BLFS中找到。
对于可能出现此问题的每个设备(即使问题不存在于当前的Linux发行版中)，请在/sys/class或下找到相应的目录/sys/block。对于视频设备，这可能是。找出唯一标识设备的属性(通常是供应商和产品ID和/或序列号的工作方式):/sys/class/video4linux/videoX
```
udevadm info -a -p /sys/class/video4linux/video0
```
然后编写创建符号链接的规则，例如：
```
cat > /etc/udev/rules.d/83-duplicate_devs.rules << "EOF"

# Persistent symlinks for webcam and tuner
KERNEL=="video*", ATTRS{idProduct}=="1910", ATTRS{idVendor}=="0d81", \
    SYMLINK+="webcam"
KERNEL=="video*", ATTRS{device}=="0x036f", ATTRS{vendor}=="0x109e", \
    SYMLINK+="tvtuner"

EOF
```
其结果是，/dev/video0和/dev/video1设备仍然随机指向调谐器和网络摄像机(并且因此不应该被直接使用)，但是符号链接/dev/tvtuner和/dev/webcam总是指向正确的设备。

______________________________________________________________

7.5 配置系统时钟
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

###7.5.1 网络时间同步
从版本213开始，systemd发布了一个名为systemd-timesyncd的守护进程 ，可用于将系统时间与远程NTP服务器进行同步。
该守护进程不是用来替代已建立的NTP守护进程，而是作为客户端唯一的SNTP协议实现，可用于较低级的任务和资源有限的系统。
从systemd版本216开始，系统默认启用systemd-timesyncd守护进程。如果要禁用它，请发出以下命令：
```
systemctl disable systemd-timesyncd
```
该`/etc/systemd/timesyncd.conf`文件可用于更改systemd-timesyncd与之同步的NTP服务器。

请注意，当系统时钟设置为本地时间时， systemd-timesyncd 不会更新硬件时钟。

________________________________________________________

7.6 配置Linux控制台
====================================
本节讨论如何配置systemd-vconsole-setup系统服务，该服务配置虚拟控制台字体和控制台键盘映射。

该systemd-vconsole，设置服务读取/etc/vconsole.conf的配置信息文件。确定将使用哪个键盘映射和屏幕字体。各种特定于语言的HOWTO也可以帮助解决这个问题，请参阅http://www.tldp.org/HOWTO/HOWTO-INDEX/other-lang.html。检查localectl list-keymaps输出以获取有效控制台键盘映射的列表。在/usr/share/consolefonts目录中查找有效的屏幕字体。

该/etc/vconsole.conf文件应该包含以下格式的行：VARIABLE =“value”。以下变量被认可：

######KEYMAP
此变量指定键盘的键映射表。如果未设置，则默认为us。

######KEYMAP_TOGGLE
此变量可用于配置第二个切换键映射，并且默认情况下未设置。

######FONT
该变量指定虚拟控制台使用的字体。

######FONT_MAP
该变量指定要使用的控制台映射。

######FONT_UNIMAP
该变量指定Unicode字体映射。

德国键盘和控制台的例子如下：
```
cat > /etc/vconsole.conf << "EOF"
KEYMAP=de-latin1
FONT=Lat2-Terminus16
EOF
```
您可以使用localectl实用程序在运行时更改KEYMAP值：
```
localectl set-keymap MAP
```
```
    [注意]
    请注意，localectl命令只能在完全进入LFS系统下才能执行。
```
您还可以使用localectl实用程序和相应的参数来更改X11键盘布局，型号，变体和选项：
```
localectl set-x11-keymap LAYOUT [MODEL] [VARIANT] [OPTIONS]
```
要列出localectl set-x11-keymap参数的可能值，请使用下列参数运行localectl：

######list-X11-keymap-models
显示已知的X11键盘映射模型。

######list-X11-keymap-layouts
显示已知的X11键盘映射布局。

######list-X11-keymap-variants
显示已知的X11键盘映射变体。

######list-X11-keymap-optines
显示已知的X11键盘映射选项。
```
    [注意]
    使用上面列出的任何参数都需要BLFS的XKeyboard Config软件包。
```
________________________________________________________

7.8 创建/etc/inputrc文件
=================================
该inputrc文件是Readline库的配置文件，该文件在用户从终端输入一行时提供编辑功能。它通过将键盘输入转换为特定操作来工作。Readline被Bash和大多数其他shell以及许多其他应用程序使用。
大多数人不需要特定于用户的功能，因此下面的命令会创建一个/etc/inputrc 由登录的每个人使用的全局。如果您稍后决定需要基于每个用户重写默认值，则可以.inputrc在用户的主目录中创建一个 文件与修改后的映射。
有关如何编辑inputrc文件的更多信息，请参阅Readline Init File部分下的info bash。info readline也是一个很好的信息来源。 
下面是一个通用的全球范围inputrc以及解释各种选项做什么的评论。请注意，注释不能与命令位于同一行。使用以下命令创建该文件：
```
cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF
```
___________________________________________

7.9 创建/etc/shells文件
===========================
该shells文件包含系统上的登录shell列表。应用程序使用此文件来确定shell是否有效。对于每个shell，应该存在一行，由相对于目录结构根目录(/)的shell路径组成。
例如，通过chsh查阅此文件，以确定非特权用户是否可以更改自己的帐户的登录shell。如果命令名未列出，用户将被拒绝更改。
对于如`GDM`这样的应用程序，如果它找不到`/etc/shells`，则不会填充面部浏览器，或者传统上不允许使用此文件中未包含的外壳访问用户的FTP守护程序。
```
cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF
```
_________________________________________________

7.10 系统使用和配置
===================================
### 7.10.1 基本配置
该/etc/systemd/system.conf文件包含一组用于控制基本系统操作的选项。默认文件将所有条目注释掉，并显示默认设置。该文件是可以更改日志级别以及一些基本日志记录设置的位置。有关systemd-system.conf(5)每个配置选项的详细信息，请参见手册页。

_______________________________________________
#### 7.10.2 在启动时禁用屏幕清除
systemd的正常行为是在引导序列结束时清除屏幕。如果需要，可以通过运行以下命令来更改此行为：
```
mkdir -pv /etc/systemd/system/getty@tty1.service.d

cat > /etc/systemd/system/getty@tty1.service.d/noclear.conf << EOF
[Service]
TTYVTDisallocate=no
EOF
```
始终可以使用该journalctl -b 命令作为root用户来查看引导消息 。
________________________________________________________
#### 7.10.3 禁用/tmp的tmpfs
默认情况下，/tmp创建为tmpfs。如果不需要，可以通过以下来覆盖它：
```
ln -sfv /dev/null /etc/systemd/system/tmp.mount
```
或者，如果/tmp需要单独分区，则在/etc/fstab条目中指定该分区 。
```
    [警告]
    如果使用单独的分区，则不要在上面创建符号链接/tmp。这将阻止根文件系统（/）被重新挂载r / w，并使系统在启动时不可用。
```
____________________________________________________________

#### 7.10.4 配置自动文件创建和删除
有几种服务可以创建或删除文件或目录：

systemd-TMPFILES-clean.service
systemd-TMPFILES-setup-dev.service
systemd-TMPFILES-setup.service

配置文件的系统位置是`/usr/lib/tmpfiles.d/*.conf`。本地配置文件在`/etc/tmpfiles.d`。在文件`/etc/tmpfiles.d`覆盖的文件在同一个名字`/usr/lib/tmpfiles.d`。有关tmpfiles.d(5)文件格式详细信息，请参阅 手册页
请注意，`/usr/lib/tmpfiles.d/*.conf`文件的语法可能会令人困惑。例如，`/tmp`目录中文件的默认删除位于/usr/lib/tmpfiles.d/tmp.conf以下行中：
```
q / tmp 1777 root root 10d
```
类型字段q讨论创建具有配额的子卷，该配额实际上仅适用于btrfs文件系统。它引用类型v，然后引用类型d(目录)。如果is不存在，则会创建指定的目录，并根据指定调整权限和所有权。如果指定了age参数，则目录的内容将受到基于时间的清理。

如果不需要默认参数，则应该将文件复制到需要的位置/etc/tmpfiles.d并进行编辑。例如：
```
mkdir -p /etc/tempfiles.d
cp /usr/lib/tmpfiles.d/tmp.conf /etc/tempfiles.d
```
__________________________________________________________________________

#### 7.10.5 覆盖默认服务行为
单元的参数可以通过在中创建一个目录和一个配置文件来重写`/etc/systemd/system`。例如：
```
mkdir -pv /etc/systemd/system/foobar.service.d

cat > /etc/systemd/system/foobar.service.d/foobar.conf << EOF
[Service]
Restart=always
RestartSec=30
EOF
```
请参阅systemd.unit(5)手册页以获取更多信息。创建配置文件后，运行`systemctl daemon-reload`并`systemctl restart foobar`激活对服务的更改。
_____________________________________________
#### 7.10.6 调试引导序列
systemd对于不同类型的启动文件(或单元)使用统一的格式，而不是在SysVinit或BSD风格的init系统中使用纯shell脚本。systemctl命令用于启用，禁用，控制状态以及获取单元文件的状态。以下是常用命令的一些示例：

*   systemctl list-units -t <service> [--all]：列出加载的服务类型的单元文件。
*   systemctl list-units -t <target> [--all]：列出已加载的目标类型的单元文件。
*   systemctl show -p Wants <multi-user.target>：显示依赖于多用户目标的所有单位。目标是特殊的单元文件，与SysVinit下的运行级别密切相关。
*   systemctl status<servicename.service>：显示servicename服务的状态。如果没有其他单元文件具有相同的名称，例如.socket文件(它会创建一个监听套接字，它提供与inetd/xinetd类似的功能)，则.service扩展名可以省略。
____________________________________________________
#### 7.10.7 使用Systemd Journal
使用systemd-journald(默认情况下)处理登录使用systemd引导的系统，而不是典型的unix syslog守护进程。你也可以添加一个普通的syslog守护进程，并且如果需要的话可以并行工作。systemd-journald程序以二进制格式存储日记条目而不是纯文本日志文件。为了帮助解析文件，提供了命令journalctl。以下是常用命令的一些示例：

*   journalctl -r：以反向时间顺序显示日志的所有内容。
*   journalctl -uUNIT：显示与指定的UNIT文件关联的日记条目。
*   journalctl -b [= ID] -r：以反向时间顺序显示自上次成功启动（或启动ID）以来的日记帐分录。
*   journalctl -f：povides功能类似于tail -f（后面）。
____________________________________________________
####7.10.8 长时间运行的过程
从systemd-230开始，当用户会话结束时，即使使用nohup，或者进程使用daemon()或setsid()函数，所有用户进程都会被终止。这是从历史宽容环境到更严格环境的故意改变。如果您在结束用户会话后依赖长时间运行的程序(例如，屏幕或tmux)保持活动状态，则新行为可能会导致问题。在用户会话结束后，有三种方法可以保留延续的进程。
仅对选定用户启用进程延迟：普通用户有权使用`loginctl enable-linger`为其自己的用户启用进程延迟。系统管理员可以使用具有user 参数的相同命令为用户启用。该用户可以使用`systemd-run`命令启动长时间运行的进程。例如：`systemd-run --scope --user /usr/bin/screen`。如果您为用户启用延迟，即使在所有登录会话关闭后，user@.service都会保留，并且会在系统引导时自动启动。这具有明确允许和禁止进程在用户会话结束后运行的优点，但是会中断向后兼容使用nohup和实用程序等工具deamon()。
整个系统内启用过程挥之不去：您可以设置KillUserProcesses=no在`/etc/logind.conf`启用过程中挥之不去的全球所有用户。这具有将所有用户的旧方法留给明确控制的好处。

在构建时禁用：在构建 systemd时，默认情况下可以启用延迟，方法是将交换机添加`--without-kill-user-processes` 到`systemd的 configure`命令。这完全禁用了systemd在会话结束时终止用户进程的能力。

__________________________________________________

7.7 配置系统区域设置
=================================
在/etc/locale.conf下面设置必要的本地语言支持一些环境变量。正确设置它们会导致：

* 程序的输出翻译成本地语言
*   将字符正确分类为字母，数字和其他类。这对于bash在非英文语言环境中的命令行中正确接受非ASCII字符 是必需的
*   国家的正确字母排序顺序
*   适当的默认纸张尺寸
*   正确格式化货币，时间和日期值

替换<ll>与所需语言的两个字母的代码(例如，“en”)，并 <CC>与相应的国家(例如，双字母代码“GB” )。<charmap>应该替换为您所选语言环境的规范charmap。可选的修饰符如“@euro”也可能存在。

Glibc支持的所有语言环境列表可以通过运行以下命令获得：
```
locale -a
```
Charmaps可以有多个别名，例如，“ISO-8859-1”也被称为“iso8859-1”和“iso88591”。某些应用程序无法正确处理各种同义词(例如，要求将“UTF-8”写为“UTF-8”,而不是“utf8”)，因此在大多数情况下为特定语言环境选择规范名称是最安全的。要确定规范名称，请运行以下命令，其中<locale name>是由locale -a给出的输出为您的首选语言环境(在我们的示例中为“en_GB.iso88591”)。
```
LC_ALL=<locale name> locale charmap
```
对于“ en_GB.iso88591 ”语言环境，上述命令将打印：
```
ISO-8859-1
```
这会导致最终的区域设置为“en_GB.ISO-8859-1”。使用上面的启发式找到的语言环境在添加到Bash启动文件之前进行测试是非常重要的：
```
LC_ALL=<locale name> locale language
LC_ALL=<locale name> locale charmap
LC_ALL=<locale name> locale int_curr_symbol
LC_ALL=<locale name> locale int_prefix
```
上述命令应打印语言名称，区域设置使用的字符编码，本地货币和前缀以在电话号码前拨号以进入该国。如果上述任何命令失败并显示类似于下面显示的消息，则表示您的语言环境未在第6章中安装，或者默认安装Glibc不支持。
```
locale: Cannot set LC_* to default locale: No such file or directory
```
如果发生这种情况，您应该使用localedef命令安装所需的区域设置，或者考虑选择不同的区域设置。进一步的说明假定Glibc没有这样的错误消息。

超出LFS的一些软件包也可能不支持您选择的语言环境。一个示例是X库(X Window System的一部分)，如果语言环境与其内部文件中的某个字符映射名称不完全匹配，则会输出以下错误消息：
```
Warning: locale not supported by Xlib, locale set to C
```
在某些情况下，Xlib预计字符映射将以带有规范破折号的大写符号列出。例如，“ISO-8859-1”而不是“iso88591”。通过删除语言环境规范的charmap部分，也可以找到适当的规范。这可以通过在两个语言环境中运行locale charmap命令来检查。例如，为了得到Xlib识别的语言环境，必须将“de_DE.ISO-8859-15@euro”更改为“de_DE @ euro”。

如果语言环境名称不符合他们的期望，其他程序包也可能不正确地运行(但可能不一定显示任何错误消息)。在这些情况下，调查其他Linux发行版如何支持您的语言环境可能会提供一些有用的信息。

一旦确定了适当的区域设置，创建该/etc/locale.conf文件：
```
cat > /etc/locale.conf << "EOF"
LANG=<ll>_<CC>.<charmap><@modifiers>
EOF
```
请注意，您可以/etc/locale.conf使用systemd localectl实用程序进行修改。要对上述示例使用 localectl，请运行：
```
localectl set-locale LANG="<ll>_<CC>.<charmap><@modifiers>"
```
您还可以指定其他语言的特定的环境变量，例如LANG，LC_CTYPE，LC_NUMERIC或任何其他环境变量从现场输出。只需将它们与空间分开即可。一个LANG设置为en_US.UTF-8但是LC_CTYPE设置为en_US的示例是：
```
localectl set-locale LANG="en_US.UTF-8" LC_CTYPE="en_US"
```
```
    [注意]
    请注意，localectl命令只能用于使用systemd引导的系统。
```
该“C”(默认)和“EN_US”(推荐一个美国英语用户)的语言环境是不同的。“C”使用US-ASCII 7位字符集，并将字节的高位设置为无效字符。这就是为什么，例如，ls 命令将它们替换为该语言环境中的问号。此外，尝试使用来自Mutt或Pine的这些字符发送邮件会导致发送不符合RFC的邮件(发送邮件中的charset显示为“未知8位”)。所以你可以使用“C“只有在你确定你永远不需要8位字符的情况下才能使用locale。

很多程序都不支持基于UTF-8的语言环境。工作正在进行中，并在可能的情况下解决此类问题，请参阅 http://www.linuxfromscratch.org/blfs/view/8.2/introduction/locale-issues.html。

