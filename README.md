# Create a basic Linux installation for Lenovo Chromebook S330.

mkdir /opt/sysroot

docker run -it --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster /bin/bash -c "apt-get update; apt-get install -y git; git clone https://github.com/buzzy/linux.base.git; bash"

bash ./linux.base/create.sh
