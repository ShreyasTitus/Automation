# Automation

***

So first you can either download the automation file or copy and paste it into a file.

To Copy and Paste it, go to the terminal and type,

`touch automation`

Paste the copied code into it and save it.

## Install Curl

`sudo apt-get install curl `

## Make the Automation file executable

`chmod 755 automation`

## Run the code with the arguments 

```
sudo ./automation yes HOST SSID-OF-YOUR-NETWORK PASSWORD-OF-NETWORK
```

Enter yes if you want it to download image file, otherwise enter no and it is assumed to be downloaded into the same directory.
HOST is the name of the pi such as pi1
SSID is the name of your network
PASSWORD is the password of your network

***

# Enable VNC in RASPBERRY PI

***

1. `sudo raspi-config`
2. Navigate to **Interfacing Options**
3. Select **VNC > YES**

Or you can enter these lines in the terminal
```
sudo ln /usr/lib/systemd/system/vncserver-x11-serviced.service /etc/systemd/system/multi-user.target.wants/vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced
```
# Restart PI if Wireless Connection is lost

1. Store RestartPi in `/usr/local/bin/restartpi.sh`
2. Give it the required permission `sudo chmod 775 /usr/local/bin/restartpi.sh`
3. SSH into PI and use the Crontab editor `crontab -e`
4. To run the script every 5 minutes as sudo, add the following line.

` */5 * * * * /usr/bin/sudo -H /usr/local/bin/restartpi.sh >> /dev/null 2>&1 `

# If the automation program runs into errors

1. Go to **https://www.raspberrypi.org/software/** and download Raspberry Pi Imager
2. Using the Imager, install Raspberry Pi OS into the SD card
3. Move the `Wifi_SSH.sh` file to the **boot** folder
3. Run the `Wifi_SSH.sh` file
4. Delete the `Wifi_SSH.sh` file

