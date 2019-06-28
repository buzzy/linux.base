#!/bin/sh
set -e
set -x

#SKELETON
rm -fr /opt/sysroot/*
mkdir -p /opt/sysroot/usr/bin
mkdir /opt/sysroot/usr/lib
mkdir /opt/sysroot/usr/sbin
ln -s usr/bin /opt/sysroot/bin
ln -s usr/sbin /opt/sysroot/sbin
ln -s usr/lib /opt/sysroot/lib

#KERNEL:
apt-get update
apt-get install -y gcc-8-aarch64-linux-gnu gcc-8-arm-linux-gnueabihf gawk bison wget patch build-essential u-boot-tools bc vboot-kernel-utils libncurses5-dev g++-arm-linux-gnueabihf flex texinfo unzip help2man libtool-bin python3 git nano kmod
ln -s /usr/bin/aarch64-linux-gnu-gcc-8 /usr/bin/aarch64-linux-gnu-gcc
#ln -s /usr/bin/arm-linux-gnueabihf-gcc-8 /usr/bin/arm-linux-gnueabihf-gcc
cd /opt
git clone https://github.com/buzzy/linux.base.git
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export WIFIVERSION=
wget -O /opt/kernel.tar.gz https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/86596f58eadf.tar.gz
mkdir /opt/kernel
tar xfv /opt/kernel.tar.gz -C /opt/kernel
cd /opt/kernel
patch -p1 < /opt/linux.base/log2.patch
cat /opt/linux.base/config.chromeos /opt/linux.base/config.chromeos.extra > .config
cp include/linux/compiler-gcc5.h include/linux/compiler-gcc8.h
make oldconfig
make prepare
make -j$(nproc) Image
make -j$(nproc) modules
make dtbs
make -j$(nproc)
make INSTALL_MOD_PATH="/opt/sysroot" modules_install
make INSTALL_DTBS_PATH="/opt/sysroot/boot/dtbs" dtbs_install
make INSTALL_HDR_PATH="/opt/sysroot/usr" headers_install
find /opt/sysroot/usr/include \( -name .install -o -name ..install.cmd \) -delete
rm -f /opt/sysroot/lib/modules/*/{source,build}
cp /opt/linux.base/kernel.its .
mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg
dd if=/dev/zero of=bootloader.bin bs=512 count=1
#echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd quiet loglevel=0" > cmdline
echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd" > cmdline
vbutil_kernel --pack vmlinux.kpart --version 1 --vmlinuz vmlinux.uimg --arch aarch64 --keyblock /opt/linux.base/kernel.keyblock --signprivate /opt/linux.base/kernel_data_key.vbprivk --config cmdline --bootloader bootloader.bin
cp vmlinux.kpart /opt/sysroot/boot/
depmod -b /opt/sysroot -F System.map "3.18.0-19095-g86596f58eadf"

#BUSYBOX:
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
cd /opt
wget https://busybox.net/downloads/busybox-1.30.1.tar.bz2
tar xfv busybox-1.30.1.tar.bz2
cd busybox-1.30.1
cp /opt/linux.base/config.busybox .config
make -j$(nproc)
make install
mkdir /opt/sysroot/sys
mkdir -p /opt/sysroot/dev/pts
mkdir /opt/sysroot/dev/shm
mkdir /opt/sysroot/tmp
mkdir -p /opt/sysroot/var/log
chmod 1777 /opt/sysroot/tmp

#CROSSTOOL-NG:
mkdir /root/src
cd /opt
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz
tar xfv crosstool-ng-1.24.0.tar.xz
cd crosstool-ng-1.24.0
./configure --enable-local
make
cp /opt/linux.base/config.crosstool .config
./ct-ng build
#cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/arm-linux-gnueabihf/sysroot/* /opt/sysroot/

#CHROMEOS BINARIES
cp -rv /opt/linux.base/sysroot/* /opt/sysroot
mkdir /opt/sysroot/temporary
cp -rv ~/x-tools/* /opt/sysroot/temporary/

cp -rv ~/x-tools/arm-linux-gnueabihf/sysroot/lib/* /opt/sysroot/usr/lib

#cp ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/bin/* /opt/sysroot/usr/bin
#ln -s arm-linux-gnueabihf-gcc /opt/sysroot/usr/bin/gcc
#ln -s gcc /opt/sysroot/usr/bin/cc

#cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/libexec /usr




#WRONG! mkdir -p /opt/sysroot/usr/lib/gcc/arm-linux-gnueabihf/8.3.0
#WRONG! cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/libexec/gcc/arm-linux-gnueabihf/8.3.0/* /opt/sysroot/usr/lib/gcc/arm-linux-gnueabihf/8.3.0

#cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/libexec/* /opt/sysroot/usr/libexec
#mkdir -p /opt/sysroot/lib/gcc/arm-linux-gnueabihf/8.3.0

#mkdir /opt/sysroot/lib/arm-linux-gnueabihf
#cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/lib/* /opt/sysroot/lib/arm-linux-gnueabihf
#mkdir -p /opt/sysroot/usr/lib/gcc/arm-linux-gnueabihf/8
#cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/lib/* /opt/sysroot/lib/gcc/arm-linux-gnueabihf/8.3.0
