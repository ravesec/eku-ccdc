#!/bin/bash

# Author: Raven Dean
# upload.sh
#
# Description: Sends files to a slack channel using the Slack API. Check the README for instructions
#
# Dependencies: ./webhook_link curl
# Created: 02/17/2024
# Usage: <./upload.sh <file_path>>

aes_password=""
channel_id="C06K31XKY78" # Hard coded Slack channel ID

script_name="upload.sh"
usage="./$script_name <file_path>"

# Get the path of the respository root
repo_root=$(git rev-parse --show-toplevel)

# Import environment variables
source $repo_root/config_files/ekurc

# Check for the correct number of arguments
if [ "$#" -ne 1 ]
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
api_key=$(openssl enc -aes-256-cbc -d -salt -pass pass:$aes_password -in ./api_key 2>/dev/null)

if [ "$?" -eq 1 ]
then
    error "Decryption of webhook url failed. Is the password set correctly?"
    exit 1
fi

#debug $api_key

if [ ! -f "$1" ]
then
    error "$1 is not a file!"
    exit 1
fi

file_path="$1"
system_fingerprint=$(echo "$(uname -s -n -o -i) $(date)")

# Upload the file.
curl --silent -F file=@$1 -F "initial_comment=Upload from $system_fingerprint" -F channels=$channel_id -H "Authorization: Bearer $api_key" https://slack.com/api/files.upload 2>&1 > /dev/null

if [ "$?" -ne 0 ]
then
    error "File failed to upload!"
    exit 1
fi

exit 0 # Script ended successfully

