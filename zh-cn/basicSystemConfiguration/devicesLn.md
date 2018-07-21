管理设备
==============================================
## 处理重复的设备

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