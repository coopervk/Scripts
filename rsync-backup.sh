#!/bin/bash

#       SUMMARY
# Wrapper script for making backups based on timestamp using rsync, moving deleted files to /trash
#
#       ABOUT
# Script which does an rsync update that:
# -a : reserve all information about files except hard links
# -v : verbosely tells you what it does
# --delete       : deletes files in the live backup which don't exist in the live system
# --backup       : but instead of really deleting them, it moves files which no long exist to a
#                  directory
# --backup-dir   : the directory "deleted" files go to is inside of a directory inside of the live
#                  backup called /trash
# --exclude      : don't include items which are in the recycle bin
# --silent OR -s : don't have user confirm command before running so that you can call script from
#                  crontab or other script
#
#       USAGE
# Example: rsync-backup /home/user/ /media/user/externaldrive/ -s
# Backs up user files to external hard drive which is mounted at /media/user/externaldrive silently
#
#       WARNINGS
# If you wanted to backup the entire local root FS, then mount the secondary drive and just include
# ...a second --exclude "MOUNTDIR" in the command
# Directories must have trailing slash
# You must put the directories THEN the silent argument if you wish to use silent mode
# Best place for this script is probably /usr/local/sbin
# Make sure the script is executable!

# ERR 1: Did not provide two arguments
if [ $# -lt 2 ]; then
	echo "Usage: ./backup FROM TO"
	echo "Optional: Include --silent or -s as the last argument to remove need to confirm command"
	exit 1
fi

# ERR 2: Did not provide a valid path
if [ ! -d $1 ] || [ ! -d $2 ]; then
	echo "Invalid path provided"
	exit 2
fi

# ERR 3: Did not provide a path with trailing slash
if [ "${1: -1}" != "/" ] || [ "${2: -1}" != "/" ]; then
	echo "Paths must be ended with /"
	exit 3
fi

# Confirm command if not in silent mode
command="rsync -av --delete --backup --backup-dir $2trash --exclude "\$RECYCLE.BIN" $1 $2"
if [ "$3" == "--silent" ] || [ "$3" == "-s" ]; then
	echo "Proceeding silently (without prompt)"
else
	echo "Press enter to confirm command, Ctrl-C to exit"
	printf "$command"
	read
fi

# Execute command
eval $command

# Good exit
exit 0
