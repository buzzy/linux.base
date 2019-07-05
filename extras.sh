#!/bin/sh
set -e
set -x

#PREPARE
cd /opt

#exFAT
apt-get -y install pkg-config libfuse-dev
wget https://github.com/relan/exfat/releases/download/v1.3.0/fuse-exfat-1.3.0.tar.gz
tar xfv fuse-exfat-1.3.0.tar.gz
cd fuse-exfat-1.3.0
./configure --prefix=/opt/sysroot --target=arm-linux-gnueabihf
make -j$(nproc)
make install
