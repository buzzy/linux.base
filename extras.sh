#!/bin/sh
set -e
set -x

#libfuse 2
cd /opt
wget https://github.com/libfuse/libfuse/releases/download/fuse-2.9.9/fuse-2.9.9.tar.gz
tar xfv fuse-2.9.9.tar.gz
cd fuse-2.9.9

./configure \
  CFLAGS="-O2 --sysroot=/opt/sysroot"
  --prefix=/opt/sysroot/usr \
  --host=arm-linux-gnueabihf \
  --with-pkgconfigdir=/tmp \
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
./configure CFLAGS="-O2 --sysroot=/opt/sysroot" --prefix=/opt/sysroot --host=arm-linux-gnueabihf --datarootdir=/tmp
make -j$(nproc)
make install
