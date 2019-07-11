# Create a basic Linux installation for Lenovo Chromebook S330.

These simple scripts creates close to a bare-minimum Linux installation to use as a building-plate for something useful.
I wanted to create a Linux distribution with full hardware support (including GPU) to replace ChromeOS on my device. As the GPU drivers are not released as open-source, you will have to rip out the GPU drivers from ChromeOS. To be able to use the drivers, the kernel-version must match. As ChromeOS on the Lenovo Chromebook S330 uses a 64-bit Linux Kernel together with a 32-bit user space, so does this.

Linux Kernel 3.18 + Drivers + Busybox + GCC + glibc + wpa_supplicant (for wifi)

## BUILD INSTRUCTIONS

mkdir /opt/sysroot

docker run -it --mount type=bind,source=/opt/sysroot,target=/opt/sysroot --rm debian:buster /bin/bash -c "apt-get update; apt-get install -y git; cd /opt; git clone https://github.com/buzzy/linux.base.git; bash"

time bash linux.base/create.sh

## ENABLE USB BOOT

crossystem dev_boot_usb=1 dev_boot_signed_only=0

## PARTITION USB DRIVE

fdisk /dev/sda

Press G and then W

cgpt create /dev/sda

cgpt add -i 1 -t kernel -b 8192 -s 65536 -l Kernel -S 1 -T 5 -P 10 /dev/sda

cgpt show /dev/sda

Write down the number from the column "START" on the row "Sec GPT table"

cgpt add -i 2 -t data -b 73728 -s $(expr NUMBER_FROM_ABOVE - 73728) -l Root /dev/sda

mkfs.ext4 /dev/sda2

## COPY TO USB DRIVE

dd if=/opt/sysroot/boot/vmkernel.kpart /dev/sda1

cp -rv /opt/sysroot/* /dev/sda2

## CONFIGURE WIFI

wpa_passphrase SSID PASSWORD >> /etc/wpa_supplicant/wpa_supplicant.conf

ifdown mlan0

ifup mlan0

## SYSTEM LOGGER

Press ALT+F10 to view real-time syslog.

Press ALT+F1 to get back to regular console
