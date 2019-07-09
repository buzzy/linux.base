#!/bin/sh

if [ $2 == "CONNECTED" ] && [ "$IF_WIRELESS" == "dhcp" ]; then
	udhcpc -S -b -i $1 -p /var/run/udhcpc-$1.pid
fi

if [ $2 == "DISCONNECTED" ] && [ -f "/var/run/udhcpc-$1.pid" ]; then
	kill $(cat /var/run/dhcpc-$1.pid)
	kill $(cat /var/run/wpa_supplicant-$1.pid)
fi
