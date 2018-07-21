配置Linux控制台
====================================
本节讨论如何配置systemd-vconsole-setup系统服务，该服务配置虚拟控制台字体和控制台键盘映射。

该systemd-vconsole，设置服务读取/etc/vconsole.conf的配置信息文件。确定将使用哪个键盘映射和屏幕字体。各种特定于语言的HOWTO也可以帮助解决这个问题，请参阅http://www.tldp.org/HOWTO/HOWTO-INDEX/other-lang.html。检查localectl list-keymaps输出以获取有效控制台键盘映射的列表。在/usr/share/consolefonts目录中查找有效的屏幕字体。

该/etc/vconsole.conf文件应该包含以下格式的行：VARIABLE =“value”。以下变量被认可：

###### KEYMAP
此变量指定键盘的键映射表。如果未设置，则默认为us。

###### KEYMAP_TOGGLE
此变量可用于配置第二个切换键映射，并且默认情况下未设置。

###### FONT
该变量指定虚拟控制台使用的字体。

###### FONT_MAP
该变量指定要使用的控制台映射。

###### FONT_UNIMAP
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

###### list-X11-keymap-models

显示已知的X11键盘映射模型。

###### list-X11-keymap-layouts
显示已知的X11键盘映射布局。

###### list-X11-keymap-variants
显示已知的X11键盘映射变体。

###### list-X11-keymap-optines
显示已知的X11键盘映射选项。
```
    [注意]
    使用上面列出的任何参数都需要BLFS的XKeyboard Config软件包。
```