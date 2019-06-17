#!/bin/sh
set +e
set -x

#KERNEL:
apt-get update
apt-get install -y gcc-8-aarch64-linux-gnu gcc-8-arm-linux-gnueabihf gawk bison wget patch build-essential u-boot-tools bc vboot-kernel-utils libncurses5-dev g++-arm-linux-gnueabihf flex texinfo unzip help2man libtool-bin python3
ln -s /usr/bin/aarch64-linux-gnu-gcc-8 /usr/bin/aarch64-linux-gnu-gcc
ln -s /usr/bin/arm-linux-gnueabihf-gcc-8 /usr/bin/arm-linux-gnueabihf-gcc
mkdir /opt/sysroot
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
wget -O /opt/kernel.tar.gz https://chromium.googlesource.com/chromiumos/third_party/kernel/+archive/86596f58eadf.tar.gz
mkdir /opt/kernel
tar xfv /opt/kernel.tar.gz -C /opt/kernel
cd /opt/kernel
wget https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/log2.patch
patch -p1 < log2.patch
wget https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/config.chromeos
wget https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/config_append_to_chromeos.txt
cat config.chromeos config_append_to_chromeos.txt > .config
cp include/linux/compiler-gcc5.h include/linux/compiler-gcc8.h
make oldconfig
make prepare
make -j$(nproc) Image
make -j$(nproc) modules
make dtbs
make -j$(nproc)
make INSTALL_MOD_PATH="/opt/sysroot" modules_install
make INSTALL_DTBS_PATH="/opt/sysroot/boot/dtbs" dtbs_install
make INSTALL_HDR_PATH=/opt/sysroot/usr headers_install
find /opt/sysroot/usr/include \( -name .install -o -name ..install.cmd \) -delete
rm -f /opt/sysroot/lib/modules/*/{source,build}
wget https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/kernel.its
mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg
dd if=/dev/zero of=bootloader.bin bs=512 count=1
wget https://github.com/buzzy/PKGBUILDs/raw/master/core/linux-oak/kernel.keyblock
wget https://github.com/buzzy/PKGBUILDs/raw/master/core/linux-oak/kernel_data_key.vbprivk
#echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd quiet loglevel=0" > cmdline
echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd" > cmdline
vbutil_kernel --pack vmlinux.kpart --version 1 --vmlinuz vmlinux.uimg --arch aarch64 --keyblock kernel.keyblock --signprivate kernel_data_key.vbprivk --config cmdline --bootloader bootloader.bin
cp vmlinux.kpart /opt/sysroot/boot/

#BUSYBOX:
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
cd /opt
wget https://busybox.net/downloads/busybox-1.30.1.tar.bz2
tar xfv busybox-1.30.1.tar.bz2
cd busybox-1.30.1
wget -O .config https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/config.busybox
#make menuconfig
make -j$(nproc)
make install
unlink /opt/sysroot/linuxrc
mkdir /opt/sysroot/sys
mkdir -p /opt/sysroot/dev/pts
mkdir /opt/sysroot/dev/shm
mkdir /opt/sysroot/tmp
chmod 1777 /opt/sysroot/tmp

#CROSSTOOL-NG:
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz
tar xfv crosstool-ng-1.24.0.tar.xz
cd crosstool-ng-1.24.0
./configure --enable-local
make
wget -O .config https://raw.githubusercontent.com/buzzy/PKGBUILDs/master/core/linux-oak/config.crosstool
./ct-ng build
cp -rv ~/x-tools/HOST-arm-linux-gnueabihf/arm-linux-gnueabihf/arm-linux-gnueabihf/sysroot/* /opt/sysroot/

#CHROMEOS BINARIES
mkdir /opt/sysroot/temporary
cp -rv ~/x-tools/* /opt/sysroot/temporary/
