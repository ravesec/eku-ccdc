#!/bin/bash

# Author: Raven Dean
# backup.sh
#
# Description: This script creates a backup of the directory passed in the arguments.
#  This script works in tandem with ./restore.sh 
#
# Created: 02/04/2024
# Usage: <./backup.sh <directory>>

usage="\e[31mUsage: ./backup.sh <directory>\e[0m"

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo -e "\e[31mERROR: This script must be ran as root!\e[0m" >&2
    exit 1
fi

# Import environment variables
. ../../config_files/env

# Check for the correct number of arguments
if [ "$#" -ne 1 ]
then echo -e $usage
    exit 1
fi

# Check if the directory is valid
if [[ ! -d $1 ]]
then
    echo -e "\e[31m'$1' is not a valid directory. Exiting!\e[0m"
    exit 1
fi

# Create the backup directory if it doesn't exit already
mkdir -p $backup_dir

# Backup the directory and save a hash of the generated archive
backup_name=$(basename $1)
tar -czvf $backup_dir/$backup_name.tar.gz $1
sha256sum $backup_dir/$backup_name.tar.gz > $backup_dir/$backup_name-checksum

# Recursively change file attributes to protect backup integrity
chattr -R +i $backup_dir/

exit 0 # Script ended successfully

