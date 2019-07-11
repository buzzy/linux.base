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

#gettext
cd
wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.20.1.tar.gz
tar xfv gettext-0.20.1.tar.gz
cd gettext-0.20.1
./configure \
  --prefix=/usr \
  --disable-static
make -j$(nproc)
make DESTDIR=/tmp/gettext install
rm -rf /tmp/gettext/usr/share/doc
rm -rf /tmp/gettext/usr/share/gettext*
rm -rf /tmp/gettext/usr/share/info
rm -rf /tmp/gettext/usr/share/locale
rm -rf /tmp/gettext/usr/share/man
cp -rv /tmp/gettext/* /
rm -rf /tmp/gettext

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

#tcl
cd
wget https://downloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz
tar xfv tcl8.6.9-src.tar.gz
cd tcl8.6.9
./configure --prefix=/usr
make -j$(nproc)
make DESTDIR=/tmp/tcl
rm -rf /tmp/tcl/usr/man
rm -rf /tmp/tcl/usr/share
cp -rv /tmp/tcl/* /
rm -rf /tmp/tcl
ln -s /usr/bin/tclsh8.6 /usr/bin/tclsh

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
rm -rf /tmp/git/usr/share
cp -rv /tmp/git/* /
rm -rf /tmp/git



