#!/bin/bash

# Author: Raven Dean
# backup.sh
#
# Description: This script creates a backup of the files and directories passed in the arguments.
#  This script works in tandem with ./restore.sh 
#
# Created: 02/04/2024
# Usage: <./backup.sh <directory>>

#TODO: Ask for user confirmation unlesss --confirm is set
#TODO: [x] Add support for files
#TODO: Add support for infinite arguments
#TODO: Add terminal output for tar, chattr, and sha256sum
script_name="backup.sh"
usage="\e[31mUsage: ./$script_name <directory>\e[0m"

# Import environment variables
. ../../config_files/ekurc

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo "\e[31mError: This script must be ran as root!\e[0m" >&2
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -ne 1 ]
then echo $usage
    exit 1
fi

# Create necessary files and set the umask
umask 027
mkdir -p $backup_dir # Backup directory
touch $backup_dir/map # Map to original location
chattr +a $backup_dir/map # Make the map file immutable and appendable only

# Check if the argument is a valid file or directory.
if [ -d "$1" ] || [ -f "$1" ]; then
    # Create a backup and save a hash of the generated archive
    echo "\e[33m Creating a backup of '$1'...\e[0m"

    backup_path="$backup_dir/$(basename $1)-$(date +%s).tar.gz"
    checksum_path="$backup_dir/$(basename $1)-checksum"
    original_dir="$(dirname $(realpath $1))/"
    tar -czvf $backup_path $1
    sha256sum $backup_path > $checksum_path
    printf "$backup_path $original_dir\n" >> $backup_dir/map

    # Make the backups and relevant files immutable to protect backup integrity
    chattr +i $backup_path $checksum_path
else
    echo "\e[31mError: '$1': No such file or directory.\e[0m" >&2
fi

# Backup complete!
echo "\e[32mThe backup of '$1' was completed successfully!\e[0m"

exit 0 # Script ended successfully

