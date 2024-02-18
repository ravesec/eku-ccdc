#!/bin/bash

script_name="secure_repository.sh"
usage="./$script_name"

# Import environment variables
source ../../config_files/ekurc

if [ "$EUID" -ne 0 ] # Superuser requirement.
then error "This script must be ran as root!"
    exit 1
fi

# Check for the correct number of arguments
if [ "$#" -gt 0 ]
then error $usage
    exit 1
fi

# Find the repo root and do o-rwx, g-w
repo_dir="$(find / -type d -name 'eku-ccdc' 2>/dev/null)"
find $repo_dir -exec chmod 0750 -- {} +
chattr +a "$repo_dir/config_files/.history"
chattr +i "$repo_dir/scripts/linux/slack/api_key" "$repo_dir/scripts/linux/slack/webhook_url"
success "Fixed repo permissions!"

exit 0 # Script ended successfully

