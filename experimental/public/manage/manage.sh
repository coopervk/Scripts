#!/bin/bash

# Functions

brightness() {
	echo "Current brightness: $(cat /sys/class/backlight/nv_backlight/brightness)"
	echo "Brightness range: 0 - $(cat /sys/class/backlight/nv_backlight/max_brightness)"
	echo -n "Brightness (q to quit): "
	read INPUT
	if [ "$INPUT" == "q" || "$INPUT" == "Q" ]
	then
		sudo su -c "echo '$INPUT' > /sys/class/backlight/nv_backlight/brightness"
		echo ""
		brightness
	fi
}

battery() {
	cat /sys/class/power_supply/BAT0/status
	cat /sys/class/power_supply/BAT0/capacity
	echo "Press enter to continue..."
	read
	#sleep 1s
}

# Main code
echo "Requesting sudo privileges..."
sudo echo ""

clear

while [ true ]
do
	echo "quit (q), brightness (br), battery (bat), volume (vol), sound source (s), bluetooth headphones (bt), launch application (la), screen settings (scr)"
	read INPUT
	echo ""

	case $INPUT in
		"q")	echo "Quitting..."
			exit;;

		"br") 	brightness;;

		"bat")	battery;;

		"vol")	echo "volume";;

		"s")	echo "sound source";;

		"bt")	echo "bluetooth";;

		"la")	echo "launch app";;

		"scr")	echo "screen";;

		*)	echo "Command not found!"
			sleep 0.5s;;
	esac

	sleep 0.5s
	clear
done

exit
