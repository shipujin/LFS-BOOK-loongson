系统使用和配置
===================================

## 基本配置

该/etc/systemd/system.conf文件包含一组用于控制基本系统操作的选项。默认文件将所有条目注释掉，并显示默认设置。该文件是可以更改日志级别以及一些基本日志记录设置的位置。有关systemd-system.conf(5)每个配置选项的详细信息，请参见手册页。

_______________________________________________
## 在启动时禁用屏幕清除
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
## 禁用/tmp的tmpfs
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

## 配置自动文件创建和删除
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

## 覆盖默认服务行为
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
## 调试引导序列
systemd对于不同类型的启动文件(或单元)使用统一的格式，而不是在SysVinit或BSD风格的init系统中使用纯shell脚本。systemctl命令用于启用，禁用，控制状态以及获取单元文件的状态。以下是常用命令的一些示例：

*   systemctl list-units -t <service> [--all]：列出加载的服务类型的单元文件。
*   systemctl list-units -t <target> [--all]：列出已加载的目标类型的单元文件。
*   systemctl show -p Wants <multi-user.target>：显示依赖于多用户目标的所有单位。目标是特殊的单元文件，与SysVinit下的运行级别密切相关。
*   systemctl status<servicename.service>：显示servicename服务的状态。如果没有其他单元文件具有相同的名称，例如.socket文件(它会创建一个监听套接字，它提供与inetd/xinetd类似的功能)，则.service扩展名可以省略。
____________________________________________________
## 使用Systemd Journal
使用systemd-journald(默认情况下)处理登录使用systemd引导的系统，而不是典型的unix syslog守护进程。你也可以添加一个普通的syslog守护进程，并且如果需要的话可以并行工作。systemd-journald程序以二进制格式存储日记条目而不是纯文本日志文件。为了帮助解析文件，提供了命令journalctl。以下是常用命令的一些示例：

*   journalctl -r：以反向时间顺序显示日志的所有内容。
*   journalctl -uUNIT：显示与指定的UNIT文件关联的日记条目。
*   journalctl -b [= ID] -r：以反向时间顺序显示自上次成功启动(或启动ID)以来的日记帐分录。
*   journalctl -f：povides功能类似于tail -f(后面)。
____________________________________________________
## 长时间运行的过程

从systemd-230开始，当用户会话结束时，即使使用nohup，或者进程使用daemon()或setsid()函数，所有用户进程都会被终止。这是从历史宽容环境到更严格环境的故意改变。如果您在结束用户会话后依赖长时间运行的程序(例如，屏幕或tmux)保持活动状态，则新行为可能会导致问题。在用户会话结束后，有三种方法可以保留延续的进程。
仅对选定用户启用进程延迟：普通用户有权使用`loginctl enable-linger`为其自己的用户启用进程延迟。系统管理员可以使用具有user 参数的相同命令为用户启用。该用户可以使用`systemd-run`命令启动长时间运行的进程。例如：`systemd-run --scope --user /usr/bin/screen`。如果您为用户启用延迟，即使在所有登录会话关闭后，user@.service都会保留，并且会在系统引导时自动启动。这具有明确允许和禁止进程在用户会话结束后运行的优点，但是会中断向后兼容使用nohup和实用程序等工具deamon()。
整个系统内启用过程挥之不去：您可以设置KillUserProcesses=no在`/etc/logind.conf`启用过程中挥之不去的全球所有用户。这具有将所有用户的旧方法留给明确控制的好处。

在构建时禁用：在构建 systemd时，默认情况下可以启用延迟，方法是将交换机添加`--without-kill-user-processes` 到`systemd的 configure`命令。这完全禁用了systemd在会话结束时终止用户进程的能力。
