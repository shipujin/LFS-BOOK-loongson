创建/etc/inputrc文件
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