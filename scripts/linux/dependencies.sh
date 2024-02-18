#!/bin/bash

# Author: Raven Dean
# dependencies.sh
#
# Description: Script that installs dependencies/packages for the github repository.
#
# Dependencies: ../../ekurc
# Created: 02/16/2024
# Usage: <./dependencies.sh>

# Edit these as required.
script_name="dependencies.sh"
usage="./$script_name <args>"

# Import environment variables
source ../../config_files/ekurc
source /etc/os_release

if [ "$EUID" -ne 0 ] # Superuser requirement.
then error "This script must be ran as root!"
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -gt 0 ]
then error $usage
    exit 1
fi

# Check repository security requirement
check_security

# Main script here...

# Determine OS/Distro

# Install packages


exit 0 # Script ended successfully

