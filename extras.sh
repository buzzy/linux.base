#!/bin/sh
set -e
set -x

#libfuse 2
cd /opt
wget https://github.com/libfuse/libfuse/releases/download/fuse-2.9.9/fuse-2.9.9.tar.gz
tar xfv fuse-2.9.9.tar.gz
cd fuse-2.9.9

./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --prefix=/opt/sysroot/usr \
  --host=arm-linux-gnueabihf \
  --datarootdir=/tmp \
  --disable-static
  
make -j$(nproc) 
make install

#libfuse 3
apt-get -y install meson
cd /opt
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.6.1/fuse-3.6.1.tar.xz
tar xfv fuse-3.6.1.tar.xz
cd fuse-3.6.1
sed -i '/^udev/,$ s/^/#/' util/meson.build
mkdir build
cd build
meson --prefix=/tmp/libfuse --cross-file /opt/linux.base/config.libfuse
ninja
ninja install
mv -vf /tmp/libfuse/lib/x86_64-linux-gnu/libfuse3.so.3* /opt/sysroot/usr/lib
ln -s libfuse3.so.3.6.1 /opt/sysroot/usr/lib/libfuse3.so
mv /tmp/libfuse/bin/fusermount3 /opt/sysroot/usr/bin
mv /tmp/libfuse/sbin/mount.fuse3 /opt/sysroot/usr/sbin
mv /tmp/libfuse/include/fuse3 /opt/sysroot/usr/include

#exFAT
cd /opt
apt-get -y install pkg-config libfuse-dev
wget https://github.com/relan/exfat/releases/download/v1.3.0/fuse-exfat-1.3.0.tar.gz
tar xfv fuse-exfat-1.3.0.tar.gz
cd fuse-exfat-1.3.0
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --prefix=/opt/sysroot \
  --host=arm-linux-gnueabihf \
  --datarootdir=/tmp
make -j$(nproc)
make install

#wireless-tools DEPRECATED!
#cd /opt
#wget https://hewlettpackard.github.io/wireless-tools/wireless_tools.29.tar.gz
#tar xfv wireless_tools.29.tar.gz
#cd wireless_tools.29
#patch -Np1 -i /opt/linux.base/patches/wireless_tools-29-fix_iwlist_scanning-1.patch
#make CC=arm-linux-gnueabihf-gcc -j$(nproc)
#make PREFIX=/opt/sysroot/usr INSTALL_MAN=/tmp install

#bison
cd /opt
wget http://ftp.twaren.net/Unix/GNU/gnu/bison/bison-3.4.1.tar.xz
tar xfv bison-3.4.1.tar.xz
cd bison-3.4.1
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --infodir=/tmp \
  --localedir=/tmp \
  --mandir=/tmp \
  --docdir=/tmp
make -j1
make install

#flex
cd /opt
wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
tar xfv flex-2.6.4.tar.gz
cd flex-2.6.4
sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --datarootdir=/tmp \
  --disable-static
make -j$(nproc)
make install

#make
cd /opt
wget http://ftp.twaren.net/Unix/GNU/gnu/make/make-4.2.1.tar.gz
tar xfv make-4.2.1.tar.gz
cd make-4.2.1
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --datarootdir=/tmp
make
make install

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
  --prefix=/opt/sysroot/usr \
  --datarootdir=/tmp
make -j$(nproc)
make install

#pkg-config
cd /opt
wget https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz
tar xfv pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --with-internal-glib \
  --disable-host-tool \
  --mandir=/tmp \
  --docdir=/tmp \
  glib_cv_stack_grows=no \
  glib_cv_uscore=no \
  ac_cv_func_posix_getpwuid_r=no \
  ac_cv_func_posix_getgrgid_r=no
make -j$(nproc)
make install

#libnl (netlink)
cd /opt
wget https://github.com/thom311/libnl/releases/download/libnl3_4_0/libnl-3.4.0.tar.gz
tar xfv libnl-3.4.0.tar.gz
cd libnl-3.4.0
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/opt/sysroot/usr \
  --sysconfdir=/opt/sysroot/etc \
  --disable-cli \
  --datarootdir=/tmp \
  --disable-static
make -j$(nproc)
make install

#iw (tools for wifi)
cd /opt
wget https://www.kernel.org/pub/software/network/iw/iw-5.0.1.tar.xz
tar xfv iw-5.0.1.tar.xz
cd iw-5.0.1
CC=arm-linux-gnueabihf-gcc PKG_CONFIG_PATH=/opt/sysroot/lib/pkgconfig make CFLAGS="--sysroot=/opt/sysroot -O2 -s -I/opt/sysroot/usr/include/libnl3" -j$(nproc)

