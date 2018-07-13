 配置系统区域设置
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