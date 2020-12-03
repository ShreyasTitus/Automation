#
# Change IP Address to IP of your Router or a device which is always going to be online
#

ping -c4 192.168.1.1 > /dev/null
 
if [ $? != 0 ] 
then
  echo "No network connection, Restarting device now."
  sudo /sbin/shutdown -r now
fi
