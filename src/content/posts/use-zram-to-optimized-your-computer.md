---
title: 我有独特的 Archlinux 配置 0x01 - 使用 zram 优化内存
published: 2025-08-02
description: '简单介绍了如何利用内存压缩技术来使得电脑拥有更多可用的内存空间。'
image: 'https://img.goldbro.top/archlinux-wallpaper-0x01.avif'
tags: [Tech, Archlinux]
category: 'Tech'
draft: false 
lang: 'zh_CN'
---
# 什么是 zram？

> [zram](https://docs.kernel.org/admin-guide/blockdev/zram.html)，旧称为 compcache，是一个用于在内存中创建压缩的块设备的 Linux 内核模块，即带实时磁盘压缩的内存盘。

通俗来讲，这是通过压缩在内存中闲置的占用，变成更小的内容储存在内存当中。不需要用的时候压缩，需要用来再解压。

因为这个过程全程都是在内存中进行，不涉及到如 **swap** 那样的硬盘 IO 操作，所以速度和延迟都会比 **swap** 快很多，并且没有传统 **swap** 那样的 IO 读写，对硬盘也更加友好（比如在树莓派那样使用 TF 卡作为储存介质的设备）。

但是 zram 也有一定的缺点，整体操作都需要占用一部分的 CPU 来进行操作。

# 如何配置 zram？

我使用的是 ArchLinux 作为主操作系统，具体的情况如下：

![archlinux_fastfetch_20250802](https://img.goldbro.top/archlinux_fastfetch_20250802.avif")

我们遵循 [ArchLinux Wiki](https://wiki.archlinuxcn.org/wiki/Zram) 来完成一步步操作。

现代内核基本都已经合入了 zram 的驱动，所以本篇不再赘述如何启用 zram。

## 关闭 zswap

zswap 是用于与 swap 设备协同工作的压缩模块，启用 zswap 将会阻止 zram 的使用，所以第一步我们将会先关闭 zswap。

此处的禁用我们会编辑内核参数部分，实现 **永久禁用** zswap 功能。

1. 编辑 `/etc/default/grub` 文件，添加如下内容 GRUB_CMDLINE_LINUX_DEFAULT = "zswap.enabled = 0"

2. 使用对应命令重新生成 grub 文件，ArchLinux 这里使用的是 `grub-mkconfig`：

   ```bash
	sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

3. 然后再次检查 zswap 是否有效关闭。

   ```bash
	cat /sys/module/zswap/parameters/enabled
   ```

 当输出内容为 **N** 时则为关闭了 zswap。

## 使用 zram-generator 进行 zram 配置

根据 ArchWiki， 我们使用 [zram-generator](https://wiki.archlinuxcn.org/wiki/Zram#%E4%BD%BF%E7%94%A8_zram-generator) 进行配置，只需要安装对应的包即可。

```sh
sudo pacman -S zram-generator -y
```

创建 `/etc/systemd/zram-generator` 文件，并加入如下内容：

```txt
[zram0]
zram-size = min(ram / 2) # 使用本机 RAM 的一半
compression-algorithm = zstd
```

之后先执行 `daemon-reload`，再启用对应的服务即可（`zramN` 要与上面的实例编号相对应）。

```sh
sudo systemctl enable --now systemd-zram-setup@zram0.service
```

可以使用 `zramctl` 来对配置的 zram 进行查看。

```sh
zramctl
```

输出如下：

```txt
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 zstd          7.6G   4K   64B   20K         [SWAP]
```

> 据观测来说，zram-generator 配置的 zram 的优先度会自动高于已配置的 swap，系统会自动先使用 zram。

# 补充资料

本文只是简单介绍了我的 zram 配置过程，下面贴出一些优秀博文，更加详细地解释关于 zram 的内容：

- [配置 ZRAM，实现 Linux 下的内存压缩，零成本低开销获得成倍内存扩增 - yooooooo](https://www.cnblogs.com/linhaostudy/p/18324329)：该文章更加详细的介绍了关于 zram 的压缩算法和内存使用的关系。