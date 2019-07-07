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
  --prefix=/usr \
  --host=arm-linux-gnueabihf \
  --datarootdir=/tmp \
  --disable-static
  
make -j$(nproc) 
make DESTDIR=/tmp/libfuse2 install
cp -rv /tmp/libfuse2/sbin /opt/sysroot/usr
cp -rv /tmp/libfuse2/usr /opt/sysroot
rm -rf /tmp/libfuse2

#libfuse 3
apt-get -y install meson
cd /opt
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.6.1/fuse-3.6.1.tar.xz
tar xfv fuse-3.6.1.tar.xz
cd fuse-3.6.1
sed -i '/^udev/,$ s/^/#/' util/meson.build
mkdir build
cd build
meson --prefix /usr --libdir lib --cross-file /opt/linux.base/config.libfuse
ninja
DESTDIR=/tmp/libfuse3 ninja install
rm -fr /tmp/libfuse3/share
cp -rv /tmp/libfuse3/* /opt/sysroot
rm -rf /tmp/libfuse3

#exFAT
cd /opt
apt-get -y install pkg-config
wget https://github.com/relan/exfat/releases/download/v1.3.0/fuse-exfat-1.3.0.tar.gz
tar xfv fuse-exfat-1.3.0.tar.gz
cd fuse-exfat-1.3.0
FUSE_CFLAGS="-I/opt/sysroot/usr/include/fuse -D_FILE_OFFSET_BITS=64" FUSE_LIBS="-L/opt/sysroot/usr/lib -lfuse -pthread" ./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf
make -j$(nproc)
make DESTDIR=/tmp/exfat install
cp -rv /tmp/exfat/usr/local/sbin /opt/sysroot/usr
rm -rf /tmp/exfat

#wireless-tools DEPRECATED!
#cd /opt
#wget https://hewlettpackard.github.io/wireless-tools/wireless_tools.29.tar.gz
#tar xfv wireless_tools.29.tar.gz
#cd wireless_tools.29
#patch -Np1 -i /opt/linux.base/patches/wireless_tools-29-fix_iwlist_scanning-1.patch
#make CC=arm-linux-gnueabihf-gcc -j$(nproc)
#make PREFIX=/opt/sysroot/usr INSTALL_MAN=/tmp install

