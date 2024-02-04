#!/bin/bash

# Author: <author(s)>
# script_name.sh
#
# Description: A template for bash scripts created by Raven Dean. NOTE that the echo command is overriden to identify the script
#  that is putting output on the terminal.
#
# Dependencies: N/A
# Created: MM/DD/YYYY
# Usage: <./script_name.sh <args>>

# Edit these as required. ANSI color coding is used.
script_name="script_name.sh"
usage="\e[31m./$script_name <args>\e[0m"

# Import environment variables
. ../../config_files/ekurc

if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then echo "\e[31mError: This script must be ran as root!\e[0m" >&2
    exit 1
fi

# Main script here...

exit 0 # Script ended successfully

