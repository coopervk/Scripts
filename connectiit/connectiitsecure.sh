#!/bin/sh

# Variables that the user may change as they desire
INTERFACE=""                                            # The name of your wireless interface
MACADDR="$(cat /sys/class/net/$INTERFACE/address)"      # The MAC address you wish your wireless to use
DHCPCLIENT="dhclient"                                   # The command which represents your DHCP service
DHCPCLIENTOPTS="-v"                                     # The appropriate arguments for the dhcp. Empty if none.
WPACONFPATH="/etc/wpa_supplicant/wpaiit.conf"           # If changed after script has been run, there may be remaining garbage artifacts.

# Start script body
echo "Script starting...\n"

echo "Requesting root privileges..."
sudo echo ""

if [ ! -f "$WPACONFPATH" ]
then
	echo "No configuration file was found at $WPACONFPATH"

	# Start user input
	echo "Making IIT conf file..."
	echo -n "Username: "
	read USERNAME
	stty_orig=`stty -g`             # Save settings of the terminal.
	stty -echo                      # Turn off echo while typing for password.
	echo -n "Password: "
	read PASSWORD
	stty $stty_orig                 # Restore terminal settings.
	echo ""

	# Start configuration file generation
	sudo touch $WPACONFPATH
	sudo chown $(whoami) $WPACONFPATH
	echo "ctrl_interface=/var/run/wpa_supplicant\n\nnetwork={\n\tssid=\"IIT-Secure\"\n\tkey_mgmt=WPA-EAP IEEE8021X\n\teap=PEAP\n\tauth_alg=OPEN\n\tidentity=\"$USERNAME\"\n\tpassword=\"$PASSWORD\"\n\tphase1=\"tls_disable_tlsv1_2=1\"\n\tphase2=\"auth=MSCHAPv2\"\n\tpriority=9\n}" > $WPACONFPATH
fi

# Ending previous instances in order to remove chance of errors
echo "Killing previous instances of wpa_supplicant and $DHCPCLIENT"
sudo killall wpa_supplicant
sudo killall $DHCPCLIENT
echo ""

# Resetting the interface and giving it its MAC
echo "Setting wireless interface down"
sudo ip l s $INTERFACE down
echo "Changing MAC address of interface to $MACADDR"
sudo ip l s $INTERFACE a "$MACADDR"
echo "Putting interface up"
sudo ip l s $INTERFACE up
echo ""

# Starting up wpa supplicant
echo "Starting wpa supplicant"
sudo wpa_supplicant -B -i $INTERFACE -c $WPACONFPATH
echo ""

# Using your DHCP Client to request an IP on the interface provided
echo "Requesting new IP with $DHCPCLIENT"
IPADDR="$(sudo $DHCPCLIENT $DHCPCLIENTOPTS $INTERFACE | grep -i 'bound')"
echo "$IPADDR"

# Checking for any internet connection. If nothing is returned, was successful.
echo "Pinging 8.8.8.8 to check for connectivity"
NETSTATS="$(ping -c 1 -I $INTERFACE 8.8.8.8 | grep 'transmitted')"
echo "$NETSTATS\n"

# Checking for internet connection and working DNS. If nothing returned, was successful.
echo "Pinging google.com to check for DNS"
NETSTATS="$(ping -c 1 $INTERFACE google.com | grep 'transmitted')"
echo "$NETSTATS"

exit

