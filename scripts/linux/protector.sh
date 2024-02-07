#!/bin/bash

# Author: Raven Dean
# protector.sh
#
# Description: This script keeps track of the integrity of files or directories specified using the SHA-256 hashing algorithm.
#  If something is modified, it is automatically replaced with a backup and the 
#  tainted file is saved to /root/forensics/<tainted-filename.ext>.
#
# Created: 02/04/2024
# Usage: ./protector.sh <filename or directory>

usage="\e[31mUsage: ./protector.sh <filename or directory>\e[0m"

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo "\e[31mError: This script must be ran as root!\e[0m" >&2
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -ne 1 ]
then echo $usage
    exit 1
fi


if [[ -f $1 ]]

exit 0 # Script ended successfully

