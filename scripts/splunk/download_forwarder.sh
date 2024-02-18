#!/bin/bash

# Author: Raven Dean
# download_forwarder.sh
#
# Description: A quick script to download the correct splunk forwarder depending on which linux system you use.
#
# Dependencies: ./forwarder_links.txt, /etc/os-release, ../../config_files/ekurc
# Created: 02/17/2024
# Usage: <./download_forwarder.sh>

# Edit these as required.
script_name="download_forwarder.sh"
usage="./$script_name"

# Import environment variables
source ../../config_files/ekurc
source /etc/os-release

# Check for the correct number of arguments
if [ "$#" -gt 0 ]
then error $usage
    exit 1
fi

# Check repository security requirement
check_security

# OS Detection
if [ "$ID" == "centos" ] || [ "$ID" == "fedora" ]
then # Based on RHEL, use their package manager
    splunk_package="$(cat ./forwarder_links.txt | grep '.rpm$')"
    yum install wget
    wget -O splunk_forwarder.rpm $splunk_package
    #yum install ./splunk_forwarder.rpm
    info "Your package manager is yum!"
else # Must be debian based, use apt
    splunk_package="$(cat ./forwarder_links.txt | grep '.deb$')"
    apt install wget
    wget -O splunk_forwarder.deb $splunk_package
    #apt install ./splunk_forwarder.rpm
    info "Your package manager is apt!"
fi
success "The correct splunk forwarder for your OS has been downloaded. Please install it using the correct package manager."

exit 0 # Script ended successfully
