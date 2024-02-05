#!/bin/bash

# Author: Raven Dean
# backup.sh
#
# Description: This script creates a backup of the files and directories passed in the arguments.
#  This script works in tandem with ./restore.sh 
#
# Created: 02/04/2024
# Usage: <./backup.sh <directory>>

#TODO: Add support for overwriting previous backups
#TODO: Ask for user confirmation to overwrite a previous backup unlesss --confirm is set
#TODO: [x] Add support for files
#TODO: [x] Add support for infinite arguments
script_name="backup.sh"
usage="Usage: ./$script_name <directory>"

# Import environment variables
. ../../config_files/ekurc

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then error "This script must be ran as root!" >&2
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -lt 1 ]
then error $usage >&2
    exit 1
fi

# Create necessary files and set the umask
umask 027 # rw-r-----
mkdir -p $backup_dir # Backup directory
touch $backup_dir/map # Map to original location
chattr +a $backup_dir/map # Make the map file immutable and appendable only

# For each argument, check if the argument is a valid file or directory.
for item in "$@"
do
    if [ -d "$item" ] || [ -f "$item" ]; then
        info "Creating a backup of '$item'..."

        # Variable definitions. 
        # Notes:
        # The usage of 'date' is not to timestamp archives, but to make sure that no naming collisions occur when backing up multiple files with the same name. Also note that there is still a chance of collision if multiple files with the same name are backed up in the same second.
        backup_path="$backup_dir/$(basename $item)-$(date +%s).tar.gz"
        checksum_path="$backup_dir/$(basename $item)-$(date +%s)-checksum"
        original_dir="$(dirname $(realpath $item))"

        # If the original directory is not the root directory, append a /
        if [ $(dirname $item) != "/" ]
        then
            original_dir="$original_dir/"
        fi

        # Create the archive, generate it's hash, and store the original file location for later restoration
        tar -czf $backup_path $item
        if [ ! "$?" -eq 0 ]
        then
            # Something went wrong while making the backup. Abort the process and continue to the next item.
            error "Archiving failed for '$item'. Aborting backup." >&2
            rm -f $backup_path
            chattr -a $backup_dir/map
            sed -i '/$backup_path/d' $backup_dir/map
            chattr +a $backup_dir/map
            continue
        fi

        sha256sum $backup_path > $checksum_path
        printf "$backup_path $original_dir\n" >> $backup_dir/map

        # Make the backups and relevant files immutable to protect backup integrity
        chattr +i $backup_path $checksum_path

        # Backup complete!
        success "The backup of '$(realpath $item)' was completed successfully!"
    else
        error "'$item': No such file or directory." >&2
    fi
done

exit 0 # Script ended successfully

