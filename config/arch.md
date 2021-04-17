# Arch configurations and problems

记录过程，遇到类似问题可以参考。

## 记一次重装系统

给`/usr`文件夹来了个递归的`chmod -R 775 /usr`。

不愧是我。

### 硬件准备

刻录`iso`的u盘，空的移动硬盘，可以查资料的电子设备。

### 参考资料

- [一个dalao的博客](https://blog.yoitsu.moe/arch-linux/installing_arch_linux_for_complete_newbies.html)；
- [官方文档](https://wiki.archlinux.org/index.php/Installation_guide_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))；
- czg的文档。

### 联网

先使用`ip link`判断网卡有没有通电。

如果是`down`，使用下列两条命令尝试开启网卡：

```shell
rfkill unblock all
ip link set wlan0 up
```

一般这样就可以了，如果不行就等一会。

如果实在不行，我目前也不知道这么解决。

有一次就是卡在这里，明明`ip link`还是`down`，但是网卡其实已经能用了...

 使用`iwd`扫描网络：

```shell
iwctl
device list
station <device> scan
station <device> get-networks
station <device> connect <network>
```

如果是有密码的WIFI，那就输入密码。

但我使用的是学校校园网，所以得手动登录。

用`curl`登录，具体命令如下：

```shell
curl 'http://p.nju.edu.cn/api/portal/v1/login' \
-H 'Connection: keep-alive' \
--data-raw '{"domain": "default", "username": "my_username", "password": "my_password"}'
```

上边的命令是直接从开发者工具扒下来的。

最后验证网已经通了：

```shell
ping www.baidu.com
```

### 设置时区

```shell
timedatectl set-local-rtc 1 --adjust-system-clock
timedatectl set-timezone Asia/Shanghai
timedatecal set-ntp true
```

## Q&A

### efi 启动分区丢失问题

安装在移动硬盘上的系统在硬盘拔出后会丢失`bios`启动选项。

此时需要用刻入`iso`的启动盘重新安装。

`mount`及之前的步骤必须全部做完，同时，`pacstrap`一步必须保证`/mnt/boot`内`.img`等文件安装完整。简单说就是一定要做`pacstarp /mnt base linux linux-firmware`。

其余包已经安装好，不用重新下载。

`arch-chroot`后，`grub-install`和`grub-mkconfig`步骤也须小心谨慎，尤其是后者，不能只出现两行提示，一定要确保出现`found...`。

### bluetooth

蓝牙配置问题。

```shell
sudo pacman -S pulseaudio-bluetooth
sudo vim /etc/bluetooth/main.conf
```

添加自动启动配置：

```shell
[Policy]
AutoEnable=true
```

### pdf 中文显示问题

`okular`默认配置中文乱码。

通过以下命令解决：

```shell
sudo pacman -S poppler-data
```

### 图形界面死机问题

使用`ctrl + alt + fn + f2`切换到`tty2`，然后 kill 掉占内存大的程序。

使用`ctrl + alt + fn + f1`切回到图形界面。

目前思路是这个，没试过，但是切换是可以的。

### vscode 无法登录问题

报错：

```shell
Writing login information to the keychain failed with error 'The name org.freedesktop.secrets was not provided by any .service files'.
```

原回答网址在[这里](https://rtfm.co.ua/en/linux-the-nextcloud-client-qtkeychain-and-the-the-name-org-freedesktop-secrets-was-not-provided-by-any-service-files-error/)。

简而言之，下载以下两个包：

```shell
yay -S qtkeychain gnome-keyring
```

通过以下两个命令来验证是否真的存在：

```shell
ls -l /usr/share/dbus-1/services/ | grep secret
cat /usr/share/dbus-1/services/org.freedesktop.secrets.service
```

### groovy 配置

下载官方包`groovy-3.0.7`

解压至`/usr/lib/gdk`，`gdk`是我自己创建的文件夹

创建符号链接`default`指向`groovy-3.0.7`

> 模仿`pacman`安装`jdk`的方法

关于`/usr/lib`等文件夹的用途可参见`man hier`

有个问题：使用`sudo pacman -S groovy`下载的`groovy`在`/usr/share/groovy`中

这里我不知道需不需要也复制一份
