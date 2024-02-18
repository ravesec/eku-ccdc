#!/bin/bash

script_name="secure_repository.sh"
usage="./$script_name"

# Get the path of the repository root
repo_root=$(get rev-parse --show-toplevel)

# Import environment variables
source "$repo_dir/config_files/ekurc"

if [ "$EUID" -ne 0 ] # Superuser requirement.
then error "This script must be ran as root!"
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -gt 0 ]
then error $usage
    exit 1
fi

find $repo_dir -exec chmod 0750 -- {} +
chattr +a "$repo_dir/config_files/.history"
chattr +i "$repo_dir/scripts/linux/slack/api_key" "$repo_dir/scripts/linux/slack/webhook_link"
success "Fixed repo permissions!"

exit 0 # Script ended successfully

