#!/bin/sh

cd /opt
wget https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2017.3.23.tgz
tar zxfv ntfs-3g_ntfsprogs-2017.3.23.tgz
cd ntfs-3g_ntfsprogs-2017.3.23
./configure --prefix=/opt/sysroot --host=arm-linux-gnueabi --mandir=/tmp --docdir=/tmp
make -j$(nproc)
make install
