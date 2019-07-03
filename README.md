# Create a basic Linux installation for Lenovo Chromebook S330.

## BUILD INSTRUCTIONS

mkdir /opt/sysroot

docker run -it --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster /bin/bash -c "apt-get update; apt-get install -y git; cd /opt; git clone https://github.com/buzzy/linux.base.git; bash"

time bash linux.base/create.sh

## COPY TO USB DRIVE

dd if=/opt/sysroot/boot/vmkernel.kpart /dev/sda1

rsync -aAXv /opt/sysroot /dev/sda2
