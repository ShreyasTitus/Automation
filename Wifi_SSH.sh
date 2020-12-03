#!/bin/bash
# Hello Everyone, I wrote this script to add wpa_supplicant.conf and ssh file for a Headless Raspberry Pi
# The first argument is for the country code.
# Ex: Type IN for INDIA
#
# The second argument is for SSID of your network
#
#The third argument is for the password of the network
#
#chmod 755 Wifi_SSH.sh
#
# Run the file by using "sudo ./Wifi_SSH.sh COUNTRY_CODE SSID_OF_NETWORK PASSWORD_OF_NETWORK
#
if [ $# -ne 3 ]
then
	echo "Incorrect arguments supplied"
else
  echo "ARGS:"
	echo $1
	echo $2
	echo $3
# 
# We create the wpa_supplicant file
#
touch wpa_supplicant.conf
cat > wpa_supplicant.conf <<EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$1

network={
 ssid="$2"
 psk="$3"
}
EOF
#
# We create the ssh file
#
touch ssh
#
fi
#
# That's all folks :)
#
