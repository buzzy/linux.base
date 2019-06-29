# Create a basic Linux installation for Lenovo Chromebook S330.

mkdir /opt/sysroot

docker run -it -v /tmp/create.sh:/create.sh --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster apt-get update; apt-get install -y git; cd /opt; git clone https://github.com/buzzy/linux.base.git; cd linux.base; bash

bash create.sh
