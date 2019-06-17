# Create a basic Linux installation for Lenovo Chromebook S330.

wget -O /tmp/create.sh https://raw.githubusercontent.com/buzzy/linux.base/master/create.sh

mkdir /opt/sysroot

docker run -v /tmp/create.sh:/create.sh --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster bash create.sh
