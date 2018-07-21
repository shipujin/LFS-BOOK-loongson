创建/etc/shells文件
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