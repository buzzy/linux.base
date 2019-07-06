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

