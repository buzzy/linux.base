#!/bin/sh
set -e
set -x

#libtasn
cd
wget https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.13.tar.gz

#p11-kit
cd
wget https://github.com/p11-glue/p11-kit/releases/download/0.23.16.1/p11-kit-0.23.16.1.tar.gz

#make-ca
cd
wget https://github.com/djlucas/make-ca/releases/download/v1.4/make-ca-1.4.tar.xz

#curl
cd
wget https://curl.haxx.se/download/curl-7.65.1.tar.xz
wget http://www.linuxfromscratch.org/patches/blfs/svn/curl-7.65.1-fix_dns_segfaults-2.patch
tar xfv curl-7.65.1.tar.xz
cd curl-7.65.1
patch -Np1 -i ../curl-7.65.1-fix_dns_segfaults-2.patch
#./configure \
#  --prefix=/usr \
#  --disable-static \
#  --enable-threaded-resolver \
#  --with-ca-path=/etc/ssl/certs
#make -j$(nproc)

#git
cd
wget https://www.kernel.org/pub/software/scm/git/git-2.22.0.tar.xz
tar xfv git-2.22.0.tar.xz
cd git-2.22.0
./configure \
  --prefix=/usr \
  --with-gitconfig=/etc/git \
  --without-curl
make -j$(nproc)



