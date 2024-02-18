#!/bin/bash

# Author: Raven Dean
# client.sh
#
# Description: A command line app to send files and messages to slack channels.
#
# Dependencies: $repo_root/config_files/ekurc
# Created: 02/16/2024
# Usage: <./client.sh>

# Edit these as required.
script_name="client.sh"
usage="./$script_name"

# todo: Get hostname
client_dir=$(pwd)

# Get the path of the repository root
repo_root=$(git rev-parse --show-toplevel)

# Import environment variables
source $repo_root/config_files/ekurc

# Check for the correct number of arguments
if [ "$#" -gt 0 ]
then error $usage
    exit 1
fi

# Check repository security requirement
check_security

# Function to send a message
send_message() {
    echo "Sending message: $1"
    # Add your logic here (e.g., curl to an API endpoint)
}

# Function to upload a file
upload_file() {
    echo "Uploading file: $1"
    # Add your logic here (e.g., curl with file upload or scp command)
}

# Function to change channel
change_channel() {
    echo "Changing to channel: $1"
    # Add your logic here if needed
}

# Function to display help
display_help() {
    if [ -z "$1" ]
    then
        cat $client_dir/help
    else
        case $1 in
            channel)
                echo "channel <channel_id> - Change the current slack channel."
                ;;
            clear)
                echo "clear - Clear the screen."
                ;;
            exit|quit)
                echo "exit|quit - Quit the slacker client."
                ;;
            help)
                echo "help|? <message> - Displays help."
                ;;
            reset)
                echo "reset - Reset variables to default."
                ;;
            send)
                echo "send <message> - Send a text message to the slack channel."
                ;;
            upload)
                echo "upload <file_path> - Upload a file to the slack channel."
                ;;
        esac
    fi
}

# Show banner
#echo -e "\e[36m$(cat banner)\n\e[0m"

# Main loop
channel_id="C06K31XKY78"
channel_name="#slack-bot"
clear
while true; do
    echo -n -e "\e[31m*Slack-Client* \e[32m$USER \e[37mat \e[36m$(hostname) \e[37min \e[33m$(pwd) \e[37musing \e[33m$channel_name\e[0m ~\n> "
    #echo -n "> "
    echo
    warn "This client is a WORK IN PROGRESS and currently \e[31mdoes NOTHING\e[0m!!!"
    read -r cmd args

    echo
    case $cmd in
        send)
            send_message "$args"
            ;;
        upload)
            upload_file "$args"
            ;;
        exit|quit)
            exit 0
            ;;
        channel)
            change_channel "$args"
            ;;
        clear)
            clear
            ;;
        help|?)
            display_help "$args"
            ;;
        *)
            if [ ! -z "$cmd" ]
            then
                echo "Command not found: '$cmd'. Run 'help' to see a list of available commands."
            fi
            ;;
    esac
done

exit 0 # Script ended successfully

