#!/bin/bash
# Script for wpa_supplicant to run when status changes (through wpa_cli), $1 is device, $2 is status

if [ -f /var/run/udhcpc-$1.pid ]; then
 kill `cat /var/run/udhcpc-$1.pid`
fi

if [ "$2" == "CONNECTED" ]; then
	DHCP=`grep DHCP /etc/network/$1 | cut -d= -f2`
	if [ "$DHCP" == "NO" ]; then
	 IP=`grep IP /etc/network/$1 | cut -d= -f2`
	 NETMASK=`grep NETMASK /etc/network/$1 | cut -d= -f2`
	 ifconfig $1 up $IP netmask $NETMASK
	else
	 udhcpc -b -i $1 -p /var/run/udhcpc-$DEV.pid -S
	fi
	SSID=`wpa_cli -i $1 status | grep ^ssid | cut -d'=' -f2`
	echo $SSID > /tmp/wifi_ssid-$1
fi
if [ "$2" == "DISCONNECTED" ]; then
	SSID=`cat /tmp/wifi_ssid-$1`
	rm -f /tmp/wifi_ssid-$1
	ifconfig $1 0.0.0.0
	ifconfig $1 down
fi

echo $@ $SSID >> /var/log/wifi_con.log
