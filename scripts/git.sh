#!/bin/sh
set -e
set -x

#curl
cd
wget https://curl.haxx.se/download/curl-7.65.1.tar.xz
wget http://www.linuxfromscratch.org/patches/blfs/svn/curl-7.65.1-fix_dns_segfaults-2.patch
tar xfv curl-7.65.1.tar.xz
cd curl-7.65.1
patch -Np1 -i ../curl-7.65.1-fix_dns_segfaults-2.patch
./configure \
  --prefix=/usr \
  --disable-static \
  --enable-threaded-resolver \
  --with-ca-path=/etc/ssl/certs
make -j$(nproc)

exit 0

#git
cd
wget https://www.kernel.org/pub/software/scm/git/git-2.22.0.tar.xz
tar xfv 
