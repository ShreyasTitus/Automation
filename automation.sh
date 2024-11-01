#!/bin/bash
if [ $# -ne 4 ]
then
	echo "Incorrect arguments supplied"
else
	echo "ARGS:"
	echo $1
	echo $2
	echo $3
	echo $4
	#
	# Get the Raspbian image name, zipped and unzipped
	#
	IMAGE_NAME=`curl -s https://downloads.raspberrypi.org/raspbian_lite_latest \
		| grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' \
		| sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//'`
	echo "Here is IMAGE:"
	echo $IMAGE_NAME
	IMAGE_FILE_NAME_ZIPPED=`echo $IMAGE_NAME | awk -F"/" '{print $7}'`
	echo "IMAGE_FILE_NAME_ZIPPED:"
	echo $IMAGE_FILE_NAME_ZIPPED

	#
	# Download Raspbian image if option yes is passed, and unzip it.
	#
	if [ $1 == "yes" ]
	then
		echo "Getting image..."
		wget $IMAGE_NAME
		#
		# unzip the image
		#
		unzip $IMAGE_FILE_NAME_ZIPPED
	fi
	#
	# Get the unzipped name in preparation to write the image to SD card
	#
	IMAGE_FILE_NAME_UNZIPPED=`echo $IMAGE_FILE_NAME_ZIPPED | sed 's/.zip/.img/g'`
	echo "IMAGE_FILE_NAME_UNZIPPED:"
	echo $IMAGE_FILE_NAME_UNZIPPED
	#
	# Get the device name of the Linux file system (with partition #)  
	# to use to mount after the image is written
	#
	OUTPUT_DEVICE_PARTITION_BEFORE_DD=`fdisk -l | tail -1 | awk '{print $1}'`
	echo "OUTPUT_DEVICE_PARTITION_BEFORE_DD:"
	echo $OUTPUT_DEVICE_PARTITION_BEFORE_DD
	DEVICE_LENGTH=`echo ${#OUTPUT_DEVICE_PARTITION_BEFORE_DD}`
	echo "DEVICE_LENGTH:"
	echo $DEVICE_LENGTH
	#
	# Get the device name of the FAT32 file system (with partition #)  
	# to use to mount to toucxh the ssh file for allowing ssh in on  
	# first boot
	#
 
	# need this one for fat32  if there is only one partitions listed in the fdisk output.
	OUTPUT_DEVICE_PARTITION_BEFORE_DD_FAT32=`fdisk -l | tail -1 | awk '{print $1}'`
	echo "OUTPUT_DEVICE_PARTITION_BEFORE_DD_FAT32:"
	echo $OUTPUT_DEVICE_PARTITION_BEFORE_DD_FAT32
	#
	# Get the device name (without partition #) to write the image to
	#
	#
	if [ $DEVICE_LENGTH != 9 ]  
	then
	# if device contains mmcd remove the last two characters - partition number
	OUTPUT_DEVICE=`echo $OUTPUT_DEVICE_PARTITION_BEFORE_DD | sed 's/.\{2\}$//'`
	echo "OUTPUT_DEVICE if length not equal 9: $OUTPUT_DEVICE"
	else
	# otherwise just remove all numbers
	OUTPUT_DEVICE=`echo $OUTPUT_DEVICE_PARTITION_BEFORE_DD | sed 's/[0-9]*//g'`
	echo "OUTPUT_DEVICE if length is equal 9: $OUTPUT_DEVICE"
	fi
	echo "OUTPUT_DEVICE:"
	echo $OUTPUT_DEVICE
	#
	# Run dd command
	#
	#if [ $1 == "yes" ] || [ $1 == "dd" ]
	#then
		echo "dd command that will be executed:"
		echo "dd bs=4M if=$IMAGE_FILE_NAME_UNZIPPED of=$OUTPUT_DEVICE status=progress"
		dd bs=4M if=$IMAGE_FILE_NAME_UNZIPPED of=$OUTPUT_DEVICE status=progress
	#fi
	#
	# make the mount directory
	#
	if [ ! -d "$DIRECTORY" ]; then
		# Script will enter here if $DIRECTORY doesn't exist.
		mkdir -p /mnt/pi
	fi
	#
	# Get linux partition after the dd command has ran, now we have the
	# linux file system we will mount to change the config files for
	# network, hosts table, wireless config to connect to the WIFI on first boot.
	#
	OUTPUT_DEVICE_PARTITION_TO_MOUNT=`fdisk -l | tail -1 | awk '{print $1}'`
	echo "Here is the partition that will be mounted after the dd command is executed"
	echo "$OUTPUT_DEVICE_PARTITION_TO_MOUNT:" $OUTPUT_DEVICE_PARTITION_TO_MOUNT
	#
	#
	#
	#
	# mount the Linux filesystem  
	#
	echo "Here is the mount command:"
	echo "mount $OUTPUT_DEVICE_PARTITION_TO_MOUNT /mnt/pi"
	echo $OUTPUT_DEVICE_PARTITION_TO_MOUNT
	mount $OUTPUT_DEVICE_PARTITION_TO_MOUNT /mnt/pi
	#
	#
	#
	cat <<EOF > /mnt/pi/etc/hosts
127.0.0.1       localhost
::1	     localhost ip6-localhost ip6-loopback
ff02::1	 ip6-allnodes
ff02::2	 ip6-allrouters
127.0.1.1       salt salt.home
192.168.2.100   salt salt.home pi1 pi1.home
192.168.2.101   pi2 pi2.home
192.168.2.102   pi3 pi3.home
192.168.2.103   kodi kodi.home
192.168.2.104   test test.home
EOF
	#
	cat <<EOF > /mnt/pi/etc/hostname
$2
EOF
	# Now customize the host table based on the pi installed ($3) pi1 is default
	# so there is no if statement for it.
	#
	if [ $2 == "pi2" ]
	then
		echo "Setting hosts in /etc/hosts..."
		#
		# get the name of the zipped image and unzip the image
		#
		sed -i 's/127.0.1.1       salt salt.home/127.0.1.1      pi2 pi2.home/' /mnt/pi/etc/hosts
	fi
	if [ $2 == "pi3" ]
	then
		echo "Setting hosts in /etc/hosts..."
		#
		# get the name of the zipped image and unzip the image
		#
		sed -i 's/127.0.1.1       salt salt.home/127.0.1.1      pi3 pi3.home/' /mnt/pi/etc/hosts
	fi
	if [ $2 == "kodi" ]
	then
		echo "Setting hosts in /etc/hosts..."
		#
		# get the name of the zipped image and unzip the image
		#
		sed -i 's/127.0.1.1       salt salt.home/127.0.1.1      kodi kodi.home/' /mnt/pi/etc/hosts
	fi
	#
	# Configure the WIFI interface
	#
	cat <<EOF > /mnt/pi/etc/network/interfaces
source-directory /etc/network/interfaces.d
allow-hotplug wlan0
iface wlan0 inet manual
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF
	#
	# Customize the WPA supplicant
	#
	cat <<EOF > /mnt/pi/etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
ssid="$3"
psk="$4"
}
EOF
#
# make the mount directory for the fat32
#
if [ ! -d "$DIRECTORY" ]; then
	# Script will enter here if $DIRECTORY doesn't exist.
	mkdir -p /mnt/pi32
fi
#
# umount the Linux filesystem
#
#umount /mnt/pi
#
# need this one for fat32  if there are two partitions listed in the fdisk output.
#
OUTPUT_DEVICE_PARTITION_AFTER_DD_FAT32=`fdisk -l | tail -2 | head -1 | awk '{print $1}'`
echo "OUTPUT_DEVICE_PARTITION_AFTER_DD_FAT32:"
echo $OUTPUT_DEVICE_PARTITION_AFTER_DD_FAT32
#
# mount the FAT32 filesystem  
#
echo "here is the fat32 mount command:"
echo "mount $OUTPUT_DEVICE_PARTITION_AFTER_DD_FAT32 /mnt/pi32"
mount $OUTPUT_DEVICE_PARTITION_AFTER_DD_FAT32 /mnt/pi32
#
# touch the ssh file - this will setup the logic to start the ssh daemon and allow remote ssh login
#
touch /mnt/pi32/ssh
#
# umount the FAT32 filesystem
#
umount /mnt/pi
#
# umount the Linux filesystem
#
umount /mnt/pi
# end of if check for arguments
fi
