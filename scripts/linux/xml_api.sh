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

api="https://$host/api/"
commit_poll_speed=3

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

delete_user() { #delete_user <user>
    response=$(curl -sk "$api?type=config&action=delete&key=$api_key&xpath=/config/mgt-config/users/entry[@name='$1']" | xpath -q -e '/response/msg/text()')
    success "API Call: delete_user($1) : $response"
}

action_set() { # action_set <description> <xpath> <element>
    #debug "Element: $3"
    url_encoded_element="$(echo $3 | jq -sRr @uri)"
    #debug "URL encoded element: $url_encoded_element"
    response=$(curl --insecure --silent --request POST --header "X-PAN-KEY: $api_key" "$api?type=config&action=set&xpath=$2&element=$url_encoded_element" | xpath -q -e '/response/msg/text()')
    success "API Call: action_set($1) : $response"
}

check_commit_status() {
    # Check the commit status for the job in $1 and echo the result.
    response=$(curl -sk "$api?type=op&cmd=<show><jobs><id>$1</id></jobs></show>&key=$api_key")
    echo $(echo $response | xpath -e '/response/result/job/status/text()' 2>/dev/null)
}

commit() { #commit <description>
    info "Starting commit: $1"
    job_id=$(curl -sk -X POST "$api?type=commit&cmd=<commit></commit>&key=$api_key" | xpath -q -e '/response/result/job/text()')
    status=$(check_commit_status $job_id)

    while [ "$status" != "FIN" ]
    do
        info "Waiting for commit $job_id to complete..."
        sleep $commit_poll_speed
        status=$(check_commit_status $job_id)
    done

    success "Commit $job_id: '$1' complete!"
}

# Get the API Key
api_key=$(curl -sk -X GET "https://$host/api/?type=keygen&user=$user&password=$password" | xpath -q -e '/response/result/key/text()')
debug "$api_key"

# TODO: Get a list of all the administrators and delete every account except for 'admin'
delete_user "administrator"

# Create Allow-Ping Management Profile
action_set "Create Allow-Ping Management Profile" "/config/devices/entry[@name='localhost.localdomain']/network/profiles/interface-management-profile/entry[@name='Allow-Ping']" "<permitted-ip><entry name=\"172.20.240.0/24\"/><entry name=\"172.20.241.0/24\"/></permitted-ip><http>yes</http>"
commit "Test commit"

exit 0 # Script ended successfully

