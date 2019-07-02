#!/bin/sh
set -e
set -x

#FETCH NEEDED TOOLS
apt-get install -y gcc-8-aarch64-linux-gnu gcc-8-arm-linux-gnueabihf gawk bison wget patch build-essential u-boot-tools bc vboot-kernel-utils libncurses5-dev g++-arm-linux-gnueabihf flex texinfo unzip help2man libtool-bin python3 git nano kmod

#CHROMEOS BINARIES
rm -fr /opt/sysroot/*
cp -rv /opt/linux.base/sysroot/* /opt/sysroot

#KERNEL:
cd /opt
ln -s /usr/bin/aarch64-linux-gnu-gcc-8 /usr/bin/aarch64-linux-gnu-gcc
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export WIFIVERSION=
if [ ! -d "/opt/kernel" ]; then
  wget -O /opt/kernel.tar.gz https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/86596f58eadf.tar.gz
  mkdir /opt/kernel
  tar xfv /opt/kernel.tar.gz -C /opt/kernel
fi
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

#CROSSTOOL-NG:
cd /opt
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz
tar xfv crosstool-ng-1.24.0.tar.xz
cd crosstool-ng-1.24.0
./configure --enable-local
make
cp /opt/linux.base/config.crosstool .config
./ct-ng build

cp -rv /opt/gcc/arm-linux-gnueabihf/sysroot/lib/* /opt/sysroot/usr/lib

rm -fr /opt/gcc/build.log.bz2
rm -fr /opt/gcc/share
rm -fr /opt/gcc/arm-linux-gnueabihf/debug-root
rm -fr /opt/gcc/arm-linux-gnueabihf/sysroot/usr/share
rm -fr /opt/gcc/arm-linux-gnueabihf/sysroot/var
rm -fr /opt/gcc/arm-linux-gnueabihf/sysroot/lib

cp -rv /opt/gcc/* /opt/sysroot/usr

ln -s /usr/lib /opt/sysroot/usr/arm-linux-gnueabihf/sysroot/lib
ln -s arm-linux-gnueabihf-gcc /opt/sysroot/usr/bin/gcc
ln -s arm-linux-gnueabihf-gcc /opt/sysroot/usr/bin/cc

#FINALIZE
#mkdir /opt/sysroot/temporary
#cp -rv /opt/gcc/* /opt/sysroot/temporary/
