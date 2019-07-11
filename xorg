#!/bin/sh
set -e
set -x

#This file will install all dependencies for running xorg GUI

#util-macros
cd /opt
wget https://www.x.org/pub/individual/util/util-macros-1.19.2.tar.bz2
tar xfv util-macros-1.19.2.tar.bz2
cd util-macros-1.19.2
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --prefix=/usr \
  --host=arm-linux-gnueabihf \
  --sysconfdir=/etc \
  --localstatedir=/var
make DESTDIR=/tmp/util-macros install
rm -fr /tmp/util-macros/usr/share/util-macros
mv /tmp/util-macros/usr/share/pkgconfig/* /opt/sysroot/lib/pkgconfig
mv /tmp/util-macros/usr/share/aclocal/* /opt/sysroot/lib/aclocal
mv -f /tmp/util-macros/usr/share/aclocal/* /opt/sysroot/usr/share/aclocal
rm -fr /tmp/util-macros

#xorgproto
apt-get -y install meson
cd /opt
wget https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2019.1.tar.bz2
tar xfv xorgproto-2019.1.tar.bz2
cd xorgproto-2019.1
mkdir build
cd build
meson --prefix=/usr --libdir=/usr/lib --cross-file /opt/linux.base/config.libfuse
ninja
DESTDIR=/tmp/xorgproto ninja install
mv /tmp/xorgproto/usr/include/* /opt/sysroot/usr/include
mv /tmp/xorgproto/usr/share/pkgconfig/* /opt/sysroot/usr/lib/pkgconfig
rm -fr /tmp/xorgproto

#libXau
cd /opt
wget https://www.x.org/pub/individual/lib/libXau-1.0.9.tar.bz2
tar xfv libXau-1.0.9.tar.bz2
cd libXau-1.0.9
./configure \
  XAU_LIBS="-L/opt/sysroot/usr/lib"
  XAU_CFLAGS="-I/opt/sysroot/usr/include"
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --prefix=/usr \
  --host=arm-linux-gnueabihf \
  --sysconfdir=/etc \
  --localstatedir=/var

