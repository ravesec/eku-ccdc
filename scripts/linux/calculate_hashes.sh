#!/bin/bash

# Ensure root.
if [ "$EUID" -ne 0 ]
then echo "Script must be ran as root!"
	exit
fi

# Ensure parameter is valid
if [ "$1" = "" ]
then echo "USAGE: ./calculate_hashes.sh <directory>"
	exit
fi

# Make sure /var/checksums exists
if [[ ! -d /var/checksums ]]
then
	mkdir -p /var/checksums
fi

# Create the backup file
filename=$(echo $1 | cut -d / -f 1 | rev)
touch /var/checksums/$filename
chmod 444 /var/checksums/$filename

# Calculate the hashes.
find $1 -type f -print0 | xargs -0 sha1sum >> /var/checksums/$filename

echo "Hash computation of all files under $1 complete."
