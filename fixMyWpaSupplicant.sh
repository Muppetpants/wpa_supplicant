#!/bin/bash
# Make sure you are root before you run this script (sudo ./wifi.sh)
# This script is designed to create a "wpa_supplicant.conf" file for connecting to user defined SSIDs

clear
# Checks to verify that the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "THIS SCRIPT NEEDS TO BE RUN AS ROOT."
   echo "EX: sudo ./wifi.sh"
   exit 1
fi

conf="wpa_supplicant.conf"

read -p "Network SSID: " ssid
read -p "Network passphrase for $ssid: " passphrase
clear

echo "SSID: $ssid"
echo "Passphrase: $passphrase"
read -n 1 -r -s -p $'Press enter to continue if the values above are correct. Otherwise "Ctrl + c" to reenter...\n'
clear

echo "Killing previous WPA_SUPPLICANT processes."
# Get the list of process IDs
pids=$(ps aux | grep wpa | grep -v grep | awk '{print $2}')
# Loop through the process IDs and kill them
for pid in $pids; do
    sudo kill -9 $pid
    echo "Killed process with ID: $pid"
done
clear

# Runs the wpa_passphrase command to build a conf file
echo "Building conf file"
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" > $conf
echo "update_config=1" >> $conf
echo "country=US" >> $conf
echo "" >> $conf
wpa_passphrase "$ssid" "$passphrase" > $conf
clear

# Moves the conf file into /etc/wpa_supplicant
echo "Moving conf file"
sudo mv $conf /etc/wpa_supplicant/
clear

# Runs the supplicant command in the background based of user input for wireless card
echo " "
echo "Start wpa_supplicant with 'sudo wpa_supplicant -B -i $interface -c $supplicant'. Confirm reconnection after reboot"


