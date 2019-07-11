#!/bin/sh
set -e
set -x

#libffi
cd /opt
wget https://sourceware.org/ftp/libffi/libffi-3.2.1.tar.gz
tar xfv libffi-3.2.1.tar.gz
cd libffi-3.2.1
sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in
sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --datarootdir=/tmp \
  --enable-static=no
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -rf /opt/sysroot/tmp/*

#expat
cd /opt
wget https://github.com/libexpat/libexpat/releases/download/R_2_2_7/expat-2.2.7.tar.xz
tar xfv expat-2.2.7.tar.xz
cd expat-2.2.7
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --datarootdir=/tmp \
  --without-examples \
  --without-tests \
  --enable-static=no
make -j$(nproc)
make DESTDIR=/opt/sysroot install
rm -rf /opt/sysroot/tmp/*

#libxml
cd /opt
wget http://xmlsoft.org/sources/libxml2-2.9.9.tar.gz
tar xfv libxml2-2.9.9.tar.gz
cd libxml2-2.9.9
./configure \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --enable-static=no
make -j$(nproc)
make DESTDIR=/tmp/libxml install
rm -rf /tmp/libxml/usr/share/{doc,gtk-doc,man}
cp -rv /tmp/libxml/* /opt/sysroot
rm -rf /tmp/libxml

#wayland
cd /opt
wget https://wayland.freedesktop.org/releases/wayland-1.17.0.tar.xz
tar xfv wayland-1.17.0.tar.xz
cd wayland-1.17.0
./configure \
  FFI_CFLAGS="-I/opt/sysroot/usr/include" \
  FFI_LIBS="-L/opt/sysroot/usr/lib" \
  EXPAT_CFLAGS="-I/opt/sysroot/usr/include" \
  EXPAT_LIBS="-L/opt/sysroot/usr/lib" \
  LIBXML_CFLAGS="-I/opt/sysroot/usr/include" \
  LIBXML_LIBS="-L/opt/sysroot/usr/lib" \
  CFLAGS="-O2 -s --sysroot=/opt/sysroot" \
  --host=arm-linux-gnueabihf \
  --prefix=/usr \
  --disable-documentation
#make CFLAGS="--sysroot=/opt/sysroot -I/opt/sysroot/usr/include/libxml2 -L/opt/sysroot/usr/lib" -j$(nproc)
