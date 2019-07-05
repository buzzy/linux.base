#!/bin/sh
set -e
set -x

#libfuse
apt-get -y install meson
cd /opt
wget https://github.com/libfuse/libfuse/releases/download/fuse-3.6.1/fuse-3.6.1.tar.xz
tar xfv fuse-3.6.1.tar.xz
cd fuse-3.6.1
sed -i '/^udev/,$ s/^/#/' util/meson.build
mkdir build
cd build
meson --cross-file /opt/linux.base/config.libfuse
ninja
njnja install

#exFAT
cd /opt
apt-get -y install pkg-config libfuse-dev
wget https://github.com/relan/exfat/releases/download/v1.3.0/fuse-exfat-1.3.0.tar.gz
tar xfv fuse-exfat-1.3.0.tar.gz
cd fuse-exfat-1.3.0
./configure --prefix=/opt/sysroot --host=arm-linux-gnueabihf --datarootdir=/tmp
make -j$(nproc)
make install
