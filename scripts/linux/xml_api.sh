#!/bin/bash

# Author: Raven Dean
# xml_api.sh
#
# Description: A bash script that configures the firewall automatically using Palo Alto's XML API.
#
# Dependencies: ../../config_files/ekurc
# Created: 02/12/2024
# Usage: <./xml_api.sh>

# Edit variables as required.
host="192.168.1.41" # TODO: CHANGEME!!!
team_no=21 #TODO: CHANGEME!!!
user="admin"
password="Changeme!" #TODO: CHANGEME!!!
script_name="xml_api.sh"
usage="./$script_name"

api="https://$host/api/" # api baseurl
commit_poll_speed=3 # Speed (in seconds) that the script checks for the commit status

# Import environment variables
. ../../config_files/ekurc

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

action() { # action <action> <description> <xpath> <element>
    if [ "$1" != "delete" ]
    then
        url_encoded_element="$(echo $4 | jq -sRr @uri)"
        response=$(curl --insecure --request POST --header "$header" "$api?type=config&action=$1&xpath=$3&element=$url_encoded_element" | xpath -q -e '/response/msg/text()')
        debug "$response"
    else
        response=$(curl --insecure --silent --request POST --header "$header" "$api?type=config&action=delete&xpath=$3" | xpath -q -e 'response/msg/text()')
    fi

    success "API Call: action_$1($2) : $response"
}

check_commit_status() {
    # Check the commit status for the job in $1 and echo the result.
    response=$(curl --insecure --silent --request GET --header "$header" "$api?type=op&cmd=<show><jobs><id>$1</id></jobs></show>")
    echo $(echo $response | xpath -e '/response/result/job/status/text()' 2>/dev/null)
}

commit() { #commit <description>
    info "Starting commit: $1"
    job_id=$(curl --insecure --silent --request POST --header "$header" "$api?type=commit&cmd=<commit></commit>" | xpath -q -e '/response/result/job/text()')

    if [ ! -z "$job_id" ]
    then
        status=$(check_commit_status $job_id)
        while [ "$status" != "FIN" ]
        do
            info "Waiting for commit $job_id ($1) to complete..."
            sleep $commit_poll_speed
            status=$(check_commit_status $job_id)
        done
        success "Commit $job_id: '$1' complete!"
    else
        warn "No changes to commit!"
    fi

}

# Get the API Key
api_key=$(curl --insecure --silent --request GET "$api?type=keygen&user=$user&password=$password" | xpath -q -e '/response/result/key/text()')
header="X-PAN-KEY: $api_key"
debug "API_KEY: $api_key"

# TODO: Get a list of pre-existing management profiles for later deletion

user_list=$(curl --insecure --silent --request GET --header "$header" "$api?type=config&action=get&xpath=/config/mgt-config/users" | xpath -q -e '//entry/@name') # Get admin users from palo alto

readarray -t usernames <<< "$(echo $user_list | sed -e 's/name="\([^"]*\)"/\1\n/g')" # Parse the xml and put the names into an array

for username in "${usernames[@]}" # For each username except for 'admin', delete that user.
do
    if [ "$username" != "admin" ]
    then
        username=$(echo $username | xargs) # Strip username of whitespace
        action "delete" "Delete '$username' user" "/config/mgt-config/users/entry[@name='$username']"
        #delete_user "$(echo $username | xargs)"
    fi
done

# Define xpaths for quick access
mgt_profile_xpath="/config/devices/entry[@name='localhost.localdomain']/network/profiles/interface-management-profile/entry"
eth_interface_xpath="/config/devices/entry[@name='localhost.localdomain']/network/interface/ethernet/entry"

# Create Allow-Ping Management Profile
action "set" "Create Allow-Ping Management Profile" "$mgt_profile_xpath[@name='Allow-Ping']" "<permitted-ip><entry name=\"172.20.240.0/24\"/><entry name=\"172.20.241.0/24\"/></permitted-ip><http>yes</http>"

# Create Allow-HTTPS-SSH-Ping Management Profile
action "set" "Create Allow-HTTPS-SSH-Ping Management Profile" "$mgt_profile_xpath[@name='Allow-HTTPS-SSH-Ping']" "<permitted-ip><entry name=\"172.20.242.0/24\"/></permitted-ip><ping>yes</ping><ssh>yes</ssh><https>yes</https>"

# Create Nothing Management Profile
action "set" "Create Nothing Management Profile" "$mgt_profile_xpath[@name='Nothing']" "<ping>no</ping>"

action "edit" "Set Ethernet1/1 (Public) Management Profile" "$eth_interface_path[@name='ethernet1/1']" "<entry name=\"ethernet1/1\"><layer3><ndp-proxy><enabled>no</enabled></ndp-proxy><sdwan-link-settings><upstream-nat><enable>no</enable><static-ip/></upstream-nat><enable>no</enable></sdwan-link-settings><ip><entry name=\"172.20.241.254/24\"/></ip><lldp><enable>no</enable></lldp><interface-management-profile>Allow-Ping</interface-management-profile></layer3><comment>Public</comment></entry>"

commit "Commit management profiles"
exit 0 # Script ended successfully
