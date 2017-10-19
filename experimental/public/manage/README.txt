VERSION

V.0.4.0

--------------------
DISCLAIMER

-This BASH script was created by Cooper Van Kampen and released to the public on 
Saturday, October 14th, 2017.
-This BASH script is licensed under the GPLv3
-This BASH script was created with the intent of providing a simple, immediate way 
to connect to IIT-Secure.
-The version numbers of this BASH script can be read as follows:
	- V.#.$.%
		-# is the major version; large important changes.
		-$ is the minor version; small changes.
			-Even means stable
			-Odd means unstable
		-% is the working version; tiny changes that occur during the coding
		process that help track changes.

--------------------
USAGE:
	-Currently, this BASH script was designed to work on my system specifically,
	but not to the intentional exclusion of others. There are some small, specific
	directory locations which may differ from system to system.
		-Specifically, pay attention to
			-The battery name under /sys/class/power_supply
			-The backlight name under sys/class/backlight

TO START: 
	-For this version, nothing needs to be installed except sudo, all linux
	laptops should have these features
	-In the future, however, automation for sounds and such will require that you
	have pavucontrol (or MAYBE ALSA), and maybe bluez. for bluetooth headsets.
	

PREPARATION:
	-To prepare this BASH script, you must have the ability to execute it. This can be 
	done with the following command:

	$ sudo chmod +x manage.sh

	-Please note a few things about this command:
		-You will need administrator privileges to run this command.
			-This can be done with the sudo command or by becoming the
			root user.
		-The $ (or # if you are the root user) is not entered into your
		terminal. It is just indicative of the fact that you enter
		what proceeds it into your terminal.
		-This gives anyone the ability to run the shell script.
			-If this is a problem, see further usage of chmod from
			its man page, or a desirable, example rich post on the
			internet.

CONFIGURE:
	-This app doesn't officially need any configuration, but it technically does,
	as your system is different than mine.
	-This current version does not have nice little modular variables at the top,
	so sorry about that...There's a reason it is in beta!

START:
	-To start this BASH script, enter the following command, assuming you are in the
	same directory as the script:

	$ ./manage.sh

RUN:
	-A nice little prompt with clearly labeled commands will appear
	-Be warned, it will clear your screen upon completion of the first command!

--------------------
FUTURE POSSIBLE FEATURES
	-The obvious...
		-Volume
		-Sound source (speakers, headphones, etc)
			-Pavucontrol
			-ALSAMixer
		-Connect bluetooth devices
			-Saves information for you
		-Launch applications
			-nohup, &>/dev/null, terminal independent
		-Screen settings (Monitors, screen, etc)
			-Probably xrandr
	-Automatic selection of battery name for compatibility
	-Automatic selection of backlight name for compatibility

Send your suggestions to my github (coopervk), my email (coopervk@gmail.com,
cvankampen@hawk.iit.edu), or my Telegram (gdynamics). 

--------------------
OFFICIAL PATCH NOTES

V.0.4.1

-Script now exists
-Battery and brightness now added
-Add README
-Brightness and battery quit is q instead of enter, brightness checks for number in order to echo change brightness

