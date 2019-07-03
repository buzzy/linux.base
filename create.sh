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

#BINUTILS
cd /opt
wget https://ftp.yzu.edu.tw/gnu/binutils/binutils-2.32.tar.xz
tar xfv binutils-2.32.tar.xz
cd binutils-2.32.tar.xz

./configure \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot \
  --with-sysroot=/ \
  --datarootdir=/tmp \
  --disable-static \
  --enable-shared \
  --disable-multilib \
  --disable-nls

make tooldir=/opt/sysroot -j$(nproc)
make tooldir=/opt/sysroot install

#GCC
cd /opt
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-8.3.0/gcc-8.3.0.tar.xz
tar xfv gcc-8.3.0.tar.xz
cd gcc-8.3.0.tar.xz
./contrib/download_prerequisites
mkdir build
cd build

../configure \
  --host=arm-linux-gnueabihf \
  --target=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --with-sysroot=/ \
  --datarootdir=/tmp \
  --enable-shared \
  --enable-threads \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libgomp \
  --disable-libstdcxx-pch \
  --with-gnu-as \
  --with-gnu-ld \
  --enable-languages=c,c++ \
  --enable-symvers=gnu \
  --enable-__cxa_atexit \
  --enable-c99 \
  --disable-nls \
  --disable-multilib \
  --disable-static

make -j$(nproc)
make install

#GLIBC
cd /opt
wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz
tar xfv glibc-2.29.tar.xz
cd glibc-2.29
mkdir build
cd build

#FIND OUT WHY IT STILL BUILDS STATIC LIBS!!!
../configure \
  --host=arm-linux-gnueabihf \
  --prefix= \
  --includedir=/usr/include \
  --libexecdir=/usr/libexec \
  --enable-kernel=3.2 \
  --enable-stack-protector=strong \
  --disable-static \
  --enable-shared \
  --datarootdir=/tmp \
  --localstatedir=/tmp \
  --with-headers=/opt/sysroot/usr/include

make -j$(nproc)
make install DESTDIR=/opt/sysroot
rm -rf /opt/sysroot/tmp/*
