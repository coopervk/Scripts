#!/bin/bash

# Variables that the user may change as they desire
INTERFACE="wlp3s0"                                      # The name of your wireless interface
MACADDR="$(cat /sys/class/net/$INTERFACE/address)"      # The MAC address you wish your wireless to use
DHCPCLIENT=""                                   				# The command which represents your DHCP service
WPACONFPATH="/etc/wpa_supplicant/wpaiit.conf"           # If changed after script has been run, there may be remaining garbage artifacts.
NETCOM=""

# Functions
request_root() {
	printf "Requesting root privileges...\n\n"
	sudo printf ""
}

# Check for configuration file. If it does not exist, generate it
gen_config_file() {
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
		printf "ctrl_interface=/var/run/wpa_supplicant\n\nnetwork={\n\tssid=\"IIT-Secure\"\n\tkey_mgmt=WPA-EAP IEEE8021X\n\teap=PEAP\n\tauth_alg=OPEN\n\tidentity=\"$USERNAME\"\n\tpassword=\"$PASSWORD\"\n\tphase1=\"tls_disable_tlsv1_2=1\"\n\tphase2=\"auth=MSCHAPV2\"\n\tpriority=9\n}" > $WPACONFPATH
	fi
}

# Check for a DHCP client if none have been specified
check_dhcp_client() {
	if ! [ "$DHCLIENT" ]
	then
		printf "You have not specified a DCHP client! Attempting autodetection...\n"
		if ! [ "$(which dhclient)" ]
		then
			DHCPCLIENT="dhclient"
		elif ! [ "$(which dhcpcd)" ]
		then
			DHCPCLIENT="dhcpcd"
		else
			printf "ERROR! No client found! Quitting...\n"
			exit
		fi
		printf "\n"
	fi	
}

# Check for network command suites if none have been specified
detect_network_tools() {
	if ! [ "$NETCOM" ]
	then
		printf "You have not specified a network command toolset! Attempting autodetection..."
		if [ "$(which ip)" ]
		then
			NETCOM="ip"
		elif [ "$(sudo which ifconfig)" ]
		then
			NETCOM="ifconfig"
		fi
		printf "\n\n"	
	fi
}

# Ending previous instances of networking tools
reset_networking() {
	printf "Killing previous instances of wpa_supplicant and $DHCPCLIENT\n"
	sudo killall wpa_supplicant
	sudo killall $DHCPCLIENT
	printf "\n"
}

# Resetting the interface and giving it its MAC
reinit_interface() {
	if [ "$NETCOM" == "ip" ]
	then
		printf "Setting wireless interface down\n"
		sudo ip l s $INTERFACE down
		printf "Changing MAC address of interface to $MACADDR\n"
		sudo ip l s $INTERFACE a "$MACADDR"
		printf "Putting interface up\n"
		sudo ip l s $INTERFACE up
		printf "\n"
	elif [ "$NETCOM" == "ifconfig" ]
	then
		printf "Setting wireless interface down\n"
		sudo ifconfig $INTERFACE down
		printf "Changing MAC address of interface to $MACADDR\n"
		sudo ifconfig $INTERFACE hw ether $MACADDR
		printf "Putting interface up\n"
		sudo ifconfig $INTERFACE up
		printf "\n"
	fi
}

# Starts wpa supplicant
start_wpa_supplicant() {
	printf "Starting wpa supplicant\n"
	sudo wpa_supplicant -B -i $INTERFACE -c $WPACONFPATH
	printf "\n"
}

# Using your DHCP Client to request an IP on the interface provided
start_dhcp_client() {
	printf "Requesting new IP with $DHCPCLIENT\n"
	sudo $DHCPCLIENT $INTERFACE
	printf "\n\n"
}

# Tests to see if you have connection to the internet and DNS
network_test() {
	INTERNETCON="$(ping -c 1 -w 1 -I $INTERFACE 8.8.8.8 | grep '0%')"
	if ! [ "$INTERNETCON" ]
	then
		printf "0"
		exit
	fi
	DNSRES="$(ping -c 1 -w 1 -I $INTERFACE google.com | grep '0%')"
	if ! [ "$DNSRES" ]
	then
		printf "0"
		exit
	fi
	printf "1"
}
# Script body
printf "Script starting...\n\n"
if [ $(network_test) == "0" ]
then
	request_root
	gen_config_file
	check_dhcp_client
	detect_network_tools
	reset_networking
	reinit_interface
	start_wpa_supplicant
	sleep 0.5s
	start_dhcp_client
	while [ $(network_test) == "0" ]
	do
		printf "Connection failed! Trying again...\n"
		reset_networking
		reinit_interface
		start_wpa_supplicant
		sleep 0.5s
		start_dhcp_client
	done
	printf "Connected! Enjoy~\n"
else
	printf "You are already connected to WiFi!\n"
fi

exit

