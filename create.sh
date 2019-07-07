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
make CFLAGS="-O2 -s" -j$(nproc) Image
make CFLAGS="-O2 -s" -j$(nproc) modules
make dtbs
make CFLAGS="-O2 -s" -j$(nproc)
make INSTALL_MOD_PATH="/opt/sysroot" modules_install
make INSTALL_DTBS_PATH="/opt/sysroot/boot/dtbs" dtbs_install
rm -f /opt/sysroot/lib/modules/*/{source,build}
cp /opt/linux.base/kernel.its .
mkimage -D "-I dts -O dtb -p 2048" -f kernel.its vmlinux.uimg
dd if=/dev/zero of=bootloader.bin bs=512 count=1
#echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd quiet loglevel=0" > cmdline
echo "console=tty1 init=/sbin/init root=PARTUUID=%U/PARTNROFF=1 rootwait rw noinitrd" > cmdline
vbutil_kernel --pack vmlinux.kpart --version 1 --vmlinuz vmlinux.uimg --arch aarch64 --keyblock /opt/linux.base/kernel.keyblock --signprivate /opt/linux.base/kernel_data_key.vbprivk --config cmdline --bootloader bootloader.bin
cp vmlinux.kpart /opt/sysroot/boot/
depmod -b /opt/sysroot -F System.map "3.18.0-19095-g86596f58eadf"
make mrproper
make ARCH=arm headers_check
make ARCH=arm INSTALL_HDR_PATH="/opt/sysroot/usr" headers_install
find /opt/sysroot/usr/include \( -name .install -o -name ..install.cmd \) -delete

#BUSYBOX:
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
cd /opt
wget https://busybox.net/downloads/busybox-1.30.1.tar.bz2
tar xfv busybox-1.30.1.tar.bz2
cd busybox-1.30.1
cp /opt/linux.base/config.busybox .config
make CFLAGS="-O2 -s" -j$(nproc)
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
  CFLAGS="-O2 -s" \
  --host=arm-linux-gnueabihf \
  --prefix= \
  --includedir=/usr/include \
  --libexecdir=/usr/libexec \
  --datarootdir=/tmp \
  --localstatedir=/tmp \
  --with-__thread \
  --with-tls \
  --with-fp \
  --with-headers=/opt/sysroot/usr/include \
  --without-cvs \
  --without-gd \
  --enable-kernel=3.18.0 \
  --enable-stack-protector=strong \
  --enable-shared \
  --enable-add-ons=no \
  --enable-obsolete-rpc \
  --disable-profile \
  --disable-debug \
  --disable-sanity-checks \
  --disable-static \
  --disable-werror

make -j$(nproc)
make install DESTDIR=/opt/sysroot
rm -rf /opt/sysroot/tmp/*

#BINUTILS
cd /opt
wget https://ftp.yzu.edu.tw/gnu/binutils/binutils-2.32.tar.xz
tar xfv binutils-2.32.tar.xz
cd binutils-2.32

./configure \
  CFLAGS="-O2 -s" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --with-sysroot=/ \
  --with-float=hard \
  --datarootdir=/tmp \
  --disable-werror \
  --disable-multilib \
  --disable-sim \
  --disable-gdb \
  --disable-nls \
  --disable-static \
  --enable-ld=default \
  --enable-gold=yes \
  --enable-threads \
  --enable-plugins
  
make tooldir=/opt/sysroot/usr -j$(nproc)
make tooldir=/opt/sysroot/usr install

#GCC
cd /opt
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-8.3.0/gcc-8.3.0.tar.xz
tar xfv gcc-8.3.0.tar.xz
cd gcc-8.3.0
./contrib/download_prerequisites
mkdir build
cd build

../configure \
  CFLAGS="-O2 -s" \
  --host=arm-linux-gnueabihf \
  --target=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --with-sysroot=/ \
  --with-float=hard \
  --datarootdir=/tmp \
  --enable-threads=posix \
  --enable-languages=c,c++ \
  --enable-__cxa_atexit \
  --disable-libmudflap \
  --disable-libssp \
  --disable-libgomp \
  --disable-libstdcxx-pch \
  --disable-nls \
  --disable-multilib \
  --disable-libquadmath \
  --disable-libquadmath-support \
  --disable-libsanitizer \
  --disable-libmpx \
  --enable-gold \
  --enable-long-long \
  --disable-static

make -j$(nproc)
make install
ln -s /opt/sysroot/usr/bin/arm-linux-gnueabihf-gcc cc

#bison
cd /opt
wget http://ftp.twaren.net/Unix/GNU/gnu/bison/bison-3.4.1.tar.xz
tar xfv bison-3.4.1.tar.xz
cd bison-3.4.1
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --disable-yacc \
  --disable-nls \
  --infodir=/tmp \
  --localedir=/tmp \
  --mandir=/tmp \
  --docdir=/tmp
make -j1
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#flex
cd /opt
wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
tar xfv flex-2.6.4.tar.gz
cd flex-2.6.4
sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --datarootdir=/tmp \
  --disable-static
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#make
cd /opt
wget http://ftp.twaren.net/Unix/GNU/gnu/make/make-4.2.1.tar.gz
tar xfv make-4.2.1.tar.gz
cd make-4.2.1
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --datarootdir=/tmp
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#m4
cd /opt
wget https://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz
tar xfv m4-1.4.18.tar.xz
cd m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --datarootdir=/tmp
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#pkg-config
cd /opt
wget https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
tar xfv pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --with-internal-glib \
  --disable-host-tool \
  --mandir=/tmp \
  --docdir=/tmp \
  glib_cv_stack_grows=yes \
  glib_cv_uscore=no \
  ac_cv_func_posix_getpwuid_r=yes \
  ac_cv_func_posix_getgrgid_r=yes
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#libnl (netlink)
cd /opt
wget https://github.com/thom311/libnl/releases/download/libnl3_4_0/libnl-3.4.0.tar.gz
tar xfv libnl-3.4.0.tar.gz
cd libnl-3.4.0
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --sysconfdir=/etc \
  --disable-cli \
  --datarootdir=/tmp \
  --disable-static
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -fr /opt/sysroot/tmp/*

#iw (tools for wifi)
cd /opt
wget https://www.kernel.org/pub/software/network/iw/iw-5.0.1.tar.xz
tar xfv iw-5.0.1.tar.xz
cd iw-5.0.1
CC="arm-linux-gnueabihf-gcc --sysroot=/opt/sysroot" \
PKG_CONFIG_PATH=/opt/sysroot/lib/pkgconfig \
CFLAGS="--sysroot=/opt/sysroot -O2 -s -I/opt/sysroot/usr/include/libnl3" \
LDFLAGS="-L/opt/sysroot/usr/lib -lnl-3" \
make
PKG_CONFIG_PATH=/opt/sysroot/lib/pkgconfig make DESTDIR=/tmp/iw install
cp -rv /tmp/iw/usr/sbin /opt/sysroot/usr
rm -fr /tmp/iw
