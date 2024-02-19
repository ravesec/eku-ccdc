#!/bin/bash

# Author: Raven

# Ensure root.
if [ "$EUID" -ne 0 ]
then echo "This script must be ran as root!"
	exit
fi

# Get the path of the repository root
repo_root=$(git rev-parse --show-toplevel)

# Import repo environment variables
. $repo_root/config_files/ekurc

# Check repository security requirement
check_security

# Safely source /os/release
read -r ID < <(. /etc/os-release; echo $ID)

# Create Backup Folder
mkdir -p /root/bu/$ID

## Backup everything except for /dev, /proc, /sys, /tmp, /run, /mnt, /media, /root/bu \(The backup folder\), and /lost+found
rsync -aAXHv --exclude-from=$repo_root/config_files/excludelist / /root/bu/$ID

# Ask the user if they would like to calculate the hashes of the backup folder.
read -p "Would you like to calculate the hashes of everything in /root/bu/$ID?"
case "$choice" in
	y|Y ) ./calculate_hases.sh /root/bu/$ID;;
	n|N ) break;;
	* ) echo "Choose y/n.";;
esac

echo "Backup Complete!"


