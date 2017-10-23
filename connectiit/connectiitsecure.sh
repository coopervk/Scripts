#!/bin/bash

# Variables that the user may change as they desire
INTERFACE="wlp3s0"                                      # The name of your wireless interface
MACADDR="$(cat /sys/class/net/$INTERFACE/address)"      # The MAC address you wish your wireless to use
DHCPCLIENT=""                                   				# The command which represents your DHCP service
WPACONFPATH="/etc/wpa_supplicant/wpaiit.conf"           # If changed after script has been run, there may be remaining garbage artifacts.
NETCOM=""

# Start script body
printf "Script starting...\n\n"

printf "Requesting root privileges...\n\n"
sudo printf ""

printf "Checking for configuration file at $WPACONFPATH...\n\n"

if [ ! -f "$WPACONFPATH" ]
then
	printf "No configuration file was found at $WPACONFPATH\n"

	# Start user input
	printf "Making IIT conf file...\n"
	printf "Username: "
	read USERNAME
	stty_orig=`stty -g`             # Save settings of the terminal.
	stty -echo                      # Turn off echo while typing for password.
	printf "Password: "
	read PASSWORD
	stty $stty_orig                 # Restore terminal settings.
	printf "\n\n"

	# Start configuration file generation
	sudo touch $WPACONFPATH
	sudo chown $(whoami) $WPACONFPATH
	printf "ctrl_interface=/var/run/wpa_supplicant\n\nnetwork={\n\tssid=\"IIT-Secure\"\n\tkey_mgmt=WPA-EAP IEEE8021X\n\teap=PEAP\n\tauth_alg=OPEN\n\tidentity=\"$USERNAME\"\n\tpassword=\"$PASSWORD\"\n\tphase1=\"tls_disable_tlsv1_2=1\"\n\tphase2=\"auth=MSCHAPv2\"\n\tpriority=9\n}" > $WPACONFPATH
fi

if ! [ "$DHCLIENT" ]
then
	printf "You have not specified a DCHP client! Attempting autodetection...\n"
	if ! [ "$(sudo dhclient --version | grep 'command not found')" ]
	then
		DHCPCLIENT="dhclient"
	elif ! [ "$(sudo dhcpcd --version | grep 'command not found')" ]
	then
		DHCPCLIENT="dhcpcd"
	else
		printf "ERROR! No client found! Quitting...\n"
		exit
	fi
	printf "\n"
fi	

if ! [ "$NETCOM" ]
then
	printf "You have not specified a network command toolset! Attempting autodetection..."
	if ! [ "$(sudo ip -V | grep 'command not found')" ]
	then
		NETCOM="ip"
	fi
	printf "\n\n"
fi

# Ending previous instances in order to remove chance of errors
printf "Killing previous instances of wpa_supplicant and $DHCPCLIENT\n"
sudo killall wpa_supplicant
sudo killall $DHCPCLIENT
printf "\n"

# Resetting the interface and giving it its MAC
if [ "$NETCOM" == "ip" ]
then
	printf "Setting wireless interface down\n"
	sudo ip l s $INTERFACE down
	printf "Changing MAC address of interface to $MACADDR\n"
	sudo ip l s $INTERFACE a "$MACADDR"
	printf "Putting interface up\n"
	sudo ip l s $INTERFACE up
	printf "\n"
fi

# Starting up wpa supplicant
printf "Starting wpa supplicant\n"
sudo wpa_supplicant -B -i $INTERFACE -c $WPACONFPATH
printf "\n"

# Using your DHCP Client to request an IP on the interface provided
printf "Requesting new IP with $DHCPCLIENT\n"
sudo $DHCPCLIENT $INTERFACE
printf "\n\n"

# Checking for any internet connection. If nothing is returned, was successful.
printf "Pinging 8.8.8.8 to check for connectivity\n\n"
NETSTATS="$(ping -c 1 -I $INTERFACE 8.8.8.8 | grep 'transmitted')"
echo "$NETSTATS"

# Checking for internet connection and working DNS. If nothing returned, was successful.
printf "Pinging google.com to check for DNS\n"
NETSTATS="$(ping -c 1 $INTERFACE google.com | grep 'transmitted')"
echo "$NETSTATS"

exit

