#!/bin/bash

# Author: Raven Dean
# send.sh
#
# Description: Sends strings to a slack channel using webhooks. Check the README for instructions
#
# Dependencies: ./webhook_link curl
# Created: 02/17/2024
# Usage: <./send.sh <message_to_send>>

aes_password=""

script_name="send.sh"
usage="./$script_name <message>"

# Get the path of the repository root
repo_root=$(git rev-parse --show-toplevel)

# Import environment variables
. $repo_root/config_files/ekurc

# Check for the correct number of arguments
if [ "$#" -lt 1 ]
then error $usage
    exit 1
fi

# Check repository security requirement
check_security

if [ -z "$aes_password" ]
then
    error "Password not set! Edit this script to change the password."
    exit 1
fi

info "This script requires 'openssl' and 'jq'!"
webhook_url=$(openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 1000000 -d -salt -pass pass:$aes_password -in ./webhook_link 2>/dev/null)

if [ "$?" -eq 1 ]
then
    error "Decryption of webhook url failed. Is the password set correctly?"
    exit 1
fi

message="$@"
payload=$(jq -nc --arg text "$message" '{"text": $text}')

# Send the message.
curl --silent -X POST -H 'Content-type: application/json' --data "$payload" "$webhook_url" 2>&1 > /dev/null

if [ "$?" -ne 0 ]
then
    error "Message failed to send!"
    exit 1
fi

exit 0 # Script ended successfully

