#!/bin/bash

# Ensure script is being ran as root
if [ "$EUID" -ne 0 ]
then echo "Script must be ran as root!"
	exit
fi

# Check for directory root argument
if [ "$1" = "" ]
then echo "USAGE: ./integrity.sh <directory root>"
	exit
fi

#Ensure /tmp/checksums and /var/log/checksums.log is read only
echo "" > /var/log/checksums.log
touch /tmp/checksums
chmod 444 /tmp/checksums /var/log/checksums.log

# Install crontab from config files.
crontab ../../config_files/crontab

# Make sure argument is a valid directory
if [[ -d $1 ]]
then
	echo "$1 is a valid directory, continuing!"
	# Calculate all checksums for all files under the specified directory root, and store them in /tmp/checksums.
	echo "Calculating checksums for all files under $1 ..."
	find $1 -type f -print0 | xargs -0 sha1sum >> /tmp/checksums
elif [[ -f $1 ]]
then
	echo "Calculating checksum for $1 ..."
	echo $1 | sha1sum >> /tmp/checksums
else
	echo "Argument passed is not a directory or file, exiting!"
	exit
fi

echo "Crontab installed. Monitor /var/log/checksums.log for file changes in $1 ."
echo "If you ran this script again for a directory you've already calculated the checksums for, clear the /tmp/checksums file!"
