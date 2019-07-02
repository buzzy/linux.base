#!/bin/sh

cd /opt
wget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz
tar zxfv ntfs-3g_ntfsprogs-2017.3.23.tgz
cd ntfs-3g_ntfsprogs-2017.3.23
./configure --prefix=/opt/sysroot/usr --host=arm-linux-gnueabi --mandir=/tmp --docdir=/tmp --disable-static --with-fuse=internal --disable-ntfsprogs --exec-prefix=/opt/sysroot/usr
make -j$(nproc)
make install
