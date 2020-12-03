#!/bin/bash
#
# gitclone the client file and cd into it
#
# 
sudo apt install pip3
pip3 install -r requirements.txt
./setup.sh
sudo ./servicesetup.sh
