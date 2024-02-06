#!/bin/bash

# Author: <author(s)>
# script_name.sh
#
# Description: A template for bash scripts created by Raven Dean. NOTE that the echo 
#  command is overriden in ../../config_files/ekurc to identify the script that is
#  putting output on the terminal.
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
then error "This script must be ran as root!" >&2
    exit 1
fi

# Main script here...

# Example logging message functions
info "Send a general information message to the terminal."
debug "Send a debug message to the terminal."
warn "Send a warning message to the terminal."
error "Send an error message to the terminal."
success "Send a success message to the terminal."

exit 0 # Script ended successfully

