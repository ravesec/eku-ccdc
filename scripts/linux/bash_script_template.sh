#!/bin/bash

# Author: <author(s)>
# script_name.sh
#
# Descriptions:
#
# Created: MM/DD/YYYY
# Usage: 

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo "This script must be ran as root!" >&2
    exit 1
fi


# Main script here...


exit 0 # Script ended successfully

