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

conf="wifi.conf"
supplicant="/etc/wpa_supplicant/$conf"

read -p "What is the name of the access point you'd like to connect to?: " ssid
read -p "What is the passphrase for $ssid: " passphrase
read -p "What wireless interface would you like to use?: " interface
clear

echo "The SSID in which you are trying to connect to is: $ssid"
echo "The wireless interface you chose: $interface"
echo "If this is not correct, please hit (Ctrl+C) now, and start over."
sleep 5
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
wpa_passphrase $ssid $passphrase > $conf
clear

# Moves the conf file into /etc/wpa_supplicant
echo "Moving conf file"
sudo mv $conf /etc/wpa_supplicant/
clear

# Runs the supplicant command in the background based of user input for wireless card
echo "Starting wpa_supplicant"
sudo wpa_supplicant -B -i $interface -c $supplicant
clear

# Waits a set amount of time before requesting an IP on said network
echo "Waiting until network is associated, then requesting an IP."
sleep 30
sudo dhclient $interface
clear
iwconfig $interface | grep $ssid
ifconfig $interface | grep "inet " | cut -d " " -f10
