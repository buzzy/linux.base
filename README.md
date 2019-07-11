# Create a basic Linux installation for Lenovo Chromebook S330.

These simple scripts creates close to a bare-minimum Linux installation to use as a building-plate for something useful.
I wanted to create a Linux distribution with full hardware support (including GPU) to replace ChromeOS on my device. As the GPU drivers are not released as open-source, you will have to rip out the GPU drivers from ChromeOS. To be able to use the drivers, the kernel-version must match. As ChromeOS on the Lenovo Chromebook S330 uses a 64-bit Linux Kernel together with a 32-bit user space, so does this.

## BUILD INSTRUCTIONS

mkdir /opt/sysroot

docker run -it --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster /bin/bash -c "apt-get update; apt-get install -y git; cd /opt; git clone https://github.com/buzzy/linux.base.git; bash"

time bash linux.base/create.sh

## COPY TO USB DRIVE

dd if=/opt/sysroot/boot/vmkernel.kpart /dev/sda1

rsync -aAXv /opt/sysroot /dev/sda2

## CONFIGURE WIFI

wpa_passphrase SSID PASSWORD >> /etc/wpa_supplicant/wpa_supplicant.conf

ifdown mlan0

ifup mlan0

## SYSTEM LOGGER

Press ALT+F10 to view real-time syslog.

Press ALT+F1 to get back to regular console
