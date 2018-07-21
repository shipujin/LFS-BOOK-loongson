通用网络配置
===========================

注：下列方法没有验证

## 网络接口配置文件

从版本209开始，systemd附带一个名为`systemd-networkd`的网络配置守护程序，该守护程序可用于基本网络配置。此外，从版本213开始，DNS名称解析可以通过`systemd-resolved`来代替静态`/etc/resolv.conf`文件来处理。默认情况下启用这两种服务。

`systemd-networkd`（和 `systemd-resolved`）的配置文件可以放在`/usr/lib/systemd/network`或中`/etc/systemd/network`。文件中的文件`/etc/systemd/network`优先级高于`/usr/lib/systemd/network`。有三种类型的配置文件：` .link`,` .netdev`和` .network`文件。为详细的说明和这些配置文件的示例内容，请参考`systemd-link(5)`，`systemd-netdev(5)`和`systemd-network(5)`手册页。

### 网络设备命名

Udev通常根据系统物理特性（如enp2s1）分配网卡接口名称。如果您不确定您的接口名称是什么，则可以在引导系统后始终运行`ip link`。

对于大多数系统，每种类型的连接只有一个网络接口。例如，有线连接的经典接口名称是eth0。无线连接通常具有名称`wifi0`或`wlan0`。

如果您更喜欢使用经典或自定义网络接口名称，则有三种替代方法可以执行此操作：

_________________________________________________

1、屏蔽udev的默认策略的.link文件：

```sh

ln -s /dev/null /etc/systemd/network/99-default.link

```
2、创建手动命名方案，例如通过命名“internet0”，“dmz0”或“lan0”之类的接口。为此，在/etc/systemd/network/中创建.link文件，为您的一个，部分或全部接口选择显式名称或更好的命名方案。例如：

```sh
cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# Change the MAC address as appropriate for your network device
MACAddress=12:34:45:78:90:AB

[Link]
Name=ether0
EOF

```
有关更多信息，请参见手册`systemd.link（5）`。

3、在`/boot/grub/grub.cfg`中，在内核命令行上传递`net.ifnames = 0`选项。

____________________________________________________

### 静态IP配置

以下命令为静态IP设置创建基本配置文件(使用systemd-networkd和systemd-resolved):

```sh

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

如果您有多个DNS服务器，则可以添加多个DNS条目。如果您打算使用静态/etc/resolv.conf文件，请不要写入DNS或Domains条目。

### DHCP配置

以下命令为IPv4 DHCP设置创建基本配置文件：

```sh

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF

```

## 创建/etc/resolv.conf文件

如果系统将要连接到Internet，则需要某种域名服务（DNS）名称解析方法将Internet域名解析为IP地址，反之亦然。最好通过将ISP服务器或网络管理员提供的DNS服务器的IP地址放入其中来实现`/etc/resolv.conf`。

### systemd-resolved配置

——————————————————————————————————————————————————

#### 注意
```
如果使用其他方法配置网络接口（例如：ppp，网络管理器等），或者使用任何类型的本地解析器（例如：bind，dnsmasq等）或任何其他生成的解析器/etc/resolv.conf （例如：resolvconf），不应使用systemd-resolved服务。

```

使用systemd-resolved进行DNS配置时，会创建该文件/run/systemd/resolve/resolv.conf。创建符号链接/etc以使用生成的文件：
```sh

    ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf

```

————————————————————————————————————————————————————

### 静态resolv.conf配置

如果需要静态/etc/resolv.conf，请通过运行以下命令创建它：
```sh

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

domain <Your Domain Name>
nameserver <IP address of your primary nameserver>
nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF

```

该domain声明可以被省略或换成了一个search声明。有关更多详细信息，请参见resolv.conf的手册页。

替换<IP address of the nameserver>为最适合设置的DNS的IP地址。通常会有多个条目（需求要求辅助服务器用于回退功能）。如果您只需要或想要一个DNS服务器，请从文件中删除第二个名称服务器行。IP地址也可以是本地网络上的路由器。

————————————————————————————————————————

#### 注意

```
该谷歌公共IPv4 DNS地址是8.8.8.8与8.8.4.4，IPv6为2001:4860:4860::8888和 2001:4860:4860::8844。

```

————————————————————————————————————————

## 配置系统主机名

在引导过程中，文件`/etc/hostname`用于建立系统的主机名。

通过运行以下命令将你想要的主机名输入`/etc/hostname`：
```sh

     echo "<lfs>" > /etc/hostname

```

`<lfs>`替代为你给计算机所想要的名字。请勿在此处输入完全限定域名（FQDN）。该信息放在`/etc/hosts`文件中。

## 自定义/etc/hosts文件

确定完全限定的域名（FQDN）以及可能在/etc/hosts 文件中使用的别名。如果使用静态地址，您还需要确定IP地址。hosts文件条目的语法是：
```

IP_address myhost.example.org aliases

```
除非计算机对Internet可见（即存在已注册的域和分配的IP地址的有效块 --大多数用户没有这个），请确保IP地址在专用网络IP地址范围内。有效范围是：
```

私有网络地址区间                      正常前缀
10.0.0.1 - 10.255.255.254           8
172.x.0.1 - 172.x.255.254           16
192.168.y.1 - 192.168.y.254         24

```
x可以是16-31范围内的任何数字。y可以是0-255范围内的任何数字。

有效的私有IP地址可以是192.168.1.1。此IP的有效FQDN可以是lfs.example.org。

即使不使用网卡，仍然需要有效的FQDN。这对于某些程序正常运行是必要的。

如果使用DHCP，DHCPv6，IPv6自动配置，或者不配置网卡，请/etc/hosts通过运行以下命令创建该文件：
```sh

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

`::1`是`127.0.0.1`的IPv6形式，表示IPv6环回接口。127.0.1.1是专门为FQDN保留的环回条目。

如果使用静态地址，请/etc/hosts通过运行此命令来创建文件：
```sh

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

`<192.168.0.2>`，` <FQDN>`和`<HOSTNAME>`值需要改变用于特定用途或要求（如果由网络/系统管理员分配一个IP地址和机器将被连接到现有的网络）。可以省略可选的别名。