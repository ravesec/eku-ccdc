#!/bin/bash

#
# This script creates a CentOS 6 and CentOS 7.0 mirror on the machine.
# At least 138GB of disk space is required.
# Author: Raven
#

# Ensure Root
if [ "$EUID" -ne 0 ]
then echo "This script must be ran as root!"
	exit
fi

# Display current disk usage
echo "Current Disk Usage:"
df -h
echo ""

# Confirm usage of disk
read -p "Running this script requires at least 138GB of disk space. Do you want to continue?"
case "$choice" in
	y|Y ) ;;
	n|N ) exit 1; break;;
	* ) echo "Choose y/n.";;
esac

# Install Nginx if it is not installed
which nginx
if [[ "$?" = "1"]]
then
	apt update
	apt install nginx-full
fi

# Get install directory from user
echo "Enter the directory where you would like to create the mirror:"
read install_dir

# Confirm validity of directory
if [[ ! -d $install_dir]]
then
	echo "$install_dir is not a directory, exiting!"
	exit 1
fi

# Confirm disk write action
read -p "You are about to mirror some directories from archive.kernel.org. This will take up at least 138 GB of disk space. Are you sure you want to continue?"
case "$choice" in
	y|Y ) break;;
	n|N ) exit 1;;
	* ) echo "Choose y/n.";;
esac

# Clone mirror.. Tell the user this could take some time.
uri="rsync://archive.kernel.org/centos-vault"
rsync -av $uri/6.0 $uri/7.9.2009 $uri/RPM-GPG-KEY-CentOS-6 $uri/RPM-GPG-KEY-CentOS-7 $uri/robots.txt $uri/readme.txt $rsync_dir 

# Configure nginx
wd=$(pwd)
cd /var/www/html
ls -s $install_dir ./mirror
cd $wd
cp ../../config_files/default_mirror_site /etc/nginx/sites-enabled/default

# Restart nginx
systemctl enable nginx
systemctl restart nginx

# Create firewall rule for port 80
# Tell the user how to access the mirror
echo "Mirror Clone Complete."
exit 0
# Done
