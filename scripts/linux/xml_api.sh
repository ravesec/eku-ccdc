#!/bin/bash

# Author: Raven Dean
# xml_api.sh
#
# Description: A bash script that configures the firewall automatically using Palo Alto's XML API.
#
# Dependencies: ../../config_files/ekurc, ../../config_files/perms_set
# Created: 02/12/2024
# Usage: <./xml_api.sh>

# Edit variables as required.
host="192.168.1.41" # TODO: CHANGEME!!!
management_subnet="192.168.1.0/24" # TODO: CHANGEME!!!
team_number=21 #TODO: CHANGEME!!!
user="admin"
password="Changeme!" #TODO: CHANGEME!!!
third_octet=$((20+$team_number))
pan_device="localhost.localdomain"
pan_vsys="vsys1"
device_xpath="/config/devices/entry[@name='$pan_device']"
vsys_xpath="/vsys/entry[@name='$pan_vsys']"
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
    api_call="API Call: action_$1($2)"
    if [ "$1" != "delete" ]
    then
        url_encoded_element="$(echo $4 | jq -sRr @uri)"
        response=$(curl --insecure --request POST --header "$header" "$api?type=config&action=$1&xpath=$3&element=$url_encoded_element" | xpath -e '/response/msg/text()')
        debug "$response"
    else
        response=$(curl --insecure --silent --request POST --header "$header" "$api?type=config&action=delete&xpath=$3" | xpath -q -e 'response/msg/text()')
    fi
    
    if [ -z "$response"  ]
    then
        error $api_call
    else
        success $api_call
    fi
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

# Display current vars to the user
warn "Ensure all variables are set correctly!\nHost: $host\nManagement Subnet: $management_subnet\nUser: $user\nPassword: $password\nTeam Number: $team_number\nThird Octet: $third_octet\nDevice: $pan_device\nVirtual System: $pan_vsys\n\nProceed running script? (y/n)\n"
read -n 1 -s yn

if [ "$yn" == "n" ]
then
    error "User quit!"
    exit 1
else
    info "Variables set correctly. Continuing..."
fi

# Get the API Key
api_key=$(curl --insecure --silent --request GET "$api?type=keygen&user=$user&password=$password" | xpath -q -e '/response/result/key/text()')
header="X-PAN-KEY: $api_key"
debug "API_KEY: $api_key"

# Define xpaths for quick access
mgmt_profile_xpath="$device_xpath/network/profiles/interface-management-profile/entry"
eth_interface_xpath="$device_xpath/network/interface/ethernet/entry"
app_group_xpath="$device_xpath$vsys_xpath/application-group/entry"
addr_object_xpath="$device_xpath$vsys_xpath/address/entry"
addr_group_xpath="$device_xpath$vsys_xpath/address-group/entry"
srvc_object_xpath="$device_xpath$vsys_xpath/service/entry"
srvc_group_xpath="$device_xpath$vsys_xpath/service-group/entry"
log_profiles_xpath="$device_xpath$vsys_xpath/log-settings/profiles/entry"

# TODO: Get a list of pre-existing management profiles for later deletion

user_list=$(curl --insecure --silent --request GET --header "$header" "$api?type=config&action=get&xpath=/config/mgt-config/users" | xpath -q -e '//entry/@name') # Get admin users from palo alto

readarray -t usernames <<< "$(echo $user_list | sed -e 's/name="\([^"]*\)"/\1\n/g')" # Parse the xml and put the names into an array

for username in "${usernames[@]}" # For each username except for 'admin', delete that user.
do
    if [ "$username" != "admin" ]
    then
        username=$(echo $username | xargs) # Strip username of whitespace
        action "delete" "Delete '$username' Management user" "/config/mgt-config/users/entry[@name='$username']"
        #delete_user "$(echo $username | xargs)"
    fi
done

# Create Allow-Ping Management Profile
action "set" "Allow-Ping Management Profile" "$mgmt_profile_xpath[@name='Allow-Ping']" "<permitted-ip><entry name=\"172.20.240.0/24\"/><entry name=\"172.20.241.0/24\"/></permitted-ip><http>yes</http>"

# Create Allow-HTTPS-Ping Management Profile
action "set" "Allow-HTTPS-Ping Management Profile" "$mgmt_profile_xpath[@name='Allow-HTTPS-Ping']" "<permitted-ip><entry name=\"172.20.242.0/24\"/></permitted-ip><ping>yes</ping><https>yes</https>"

# Create Nothing Management Profile
action "set" "Nothing Management Profile" "$mgmt_profile_xpath[@name='Nothing']" "<ping>no</ping>"

# Set ethernet1/1 (Public) Management Profile
action "edit" "Set Ethernet1/1 (Public) Management Profile" "$eth_interface_xpath[@name='ethernet1/1']" "<entry name=\"ethernet1/1\"><layer3><ndp-proxy><enabled>no</enabled></ndp-proxy><sdwan-link-settings><upstream-nat><enable>no</enable><static-ip/></upstream-nat><enable>no</enable></sdwan-link-settings><ip><entry name=\"172.20.241.254/24\"/></ip><lldp><enable>no</enable></lldp><interface-management-profile>Allow-Ping</interface-management-profile></layer3><comment>Public</comment></entry>"

# Set ethernet1/2 (Internal) Management Profile
action "edit" "Set Ethernet1/2 (Internal) Management Profile" "$eth_interface_xpath[@name='ethernet1/2']" "<entry name=\"ethernet1/2\"><layer3><ndp-proxy><enabled>no</enabled></ndp-proxy><sdwan-link-settings><upstream-nat><enable>no</enable><static-ip/></upstream-nat><enable>no</enable></sdwan-link-settings><ip><entry name=\"172.20.240.254/24\"/></ip><lldp><enable>no</enable></lldp><interface-management-profile>Allow-Ping</interface-management-profile></layer3><comment>Internal</comment></entry>"

# Set ethernet1/3 (External) Management Profile
action "edit" "Set Ethernet1/3 (External) Management Profile" "$eth_interface_xpath[@name='ethernet1/3']" "<entry name=\"ethernet1/3\"><layer3><ndp-proxy><enabled>no</enabled></ndp-proxy><sdwan-link-settings><upstream-nat><enable>no</enable><static-ip/></upstream-nat><enable>no</enable></sdwan-link-settings><ip><entry name=\"172.31.$third_octet.2/29\"/></ip><lldp><enable>no</enable></lldp><interface-management-profile>Nothing</interface-management-profile></layer3><comment>External</comment></entry>"

# Set ethernet1/4 (User)
action "edit" "Set Ethernet1/4 (User) Management Profile" "$eth_interface_xpath[@name='ethernet1/4']" "<entry name=\"ethernet1/4\"><layer3><ndp-proxy><enabled>no</enabled></ndp-proxy><sdwan-link-settings><upstream-nat><enable>no</enable><static-ip/></upstream-nat><enable>no</enable></sdwan-link-settings><ip><entry name=\"172.20.242.254/24\"/></ip><lldp><enable>no</enable></lldp><interface-management-profile>Allow-HTTPS-Ping</interface-management-profile></layer3><comment>User</comment></entry>"

commit "Commit Interface Changes"

# Create Web Traffic Application Group
action "set" "Web Traffic Application Group" "$app_group_xpath[@name='web-traffic']" "<members><member>web-browsing</member><member>ssl</member><member>git</member><member>github</member></members>"

# Create Windows Updates Application Group
action "set" "Windows Updates Application Group" "$app_group_xpath[@name='windows-updates']" "<members><member>ms-update</member></members>"

# Create Linux Updates Application Group
action "set" "Linux Updates Application Group" "$app_group_xpath[@name='linux-updates']" "<members><member>apt-get</member><member>yum</member></members>"

# Create Webmail Application Group
# TODO: IMAP was removed, hopefully no backfire later
action "set" "Webmail Application Group" "$app_group_xpath[@name='webmail']" "<members><member>smtp</member><member>pop3</member></members>"

# Create ICMP-Ping Application Group
# TODO: Removed ipv6-icmp
action "set" "ICMP-Ping Application Group" "$app_group_xpath[@name='icmp-ping']" "<members><member>icmp</member><member>ping</member></members>"

# Create Active Directory Application Group
action "set" "Active Directory Application Group" "$app_group_xpath[@name='windows-active-directory']" "<members><member>active-directory</member><member>ldap</member><member>ms-ds-smb</member><member>kerberos</member></members>"

# Create Placeholder Address Object
action "set" "Placeholder Address Object" "$addr_object_xpath[@name='placeholder']" "<ip-netmask>169.254.74.75/32</ip-netmask><description>Placeholder APIPA address for the blacklist group</description>"

# Create Public Network Segment Address Object
action "set" "Public Network Segment Address Object" "$addr_object_xpath[@name='public-network-segment']" "<ip-netmask>172.20.241.0/24</ip-netmask><description>The public subnet</description>"

# Create Internal Network Segment Address Object
action "set" "Internal Network Segment Address Object" "$addr_object_xpath[@name='internal-network-segment']" "<ip-netmask>172.20.240.0/24</ip-netmask><description>The internal subnet</description>"

# Create User Network Segment Address Object
action "set" "User Network Segment Address Object" "$addr_object_xpath[@name='user-network-segment']" "<ip-netmask>172.20.242.0/24</ip-netmask><description>The user subnet</description>"

# Create Public NAT Address Object
action "set" "Public NAT Address Object" "$addr_object_xpath[@name='public-network-nat-address']" "<ip-netmask>172.25.$third_octet.151/24</ip-netmask><description>NAT address for hosts on the public subnet</description>"

# Create Internal NAT Address Object
action "set" "Internal NAT Address Object" "$addr_object_xpath[@name='internal-network-nat-address']" "<ip-netmask>172.25.$third_octet.150/24</ip-netmask><description>NAT address for hosts on the internal subnet</description>"

# Create User NAT Address Object
action "set" "User NAT Address Object" "$addr_object_xpath[@name='user-network-nat-address']" "<ip-netmask>172.25.$third_octet.152/24</ip-netmask><description>NAT address for hosts on the user subnet</description>"

# Create 2016 Docker/Remote Address Object
action "set" "2016 Docker/Remote Address Object" "$addr_object_xpath[@name='docker-remote']" "<ip-netmask>172.20.240.10/24</ip-netmask><description>Private IPv4 address for the '2016 Docker/Remote' server</description>"

# Create 2016 Docker/Remote NAT Address Object
action "set" "2016 Docker/Remote NAT Address Object" "$addr_object_xpath[@name='docker-remote-nat']" "<ip-netmask>172.25.$third_octet.97/24</ip-netmask><description>NAT IPv4 address for the '2016 Docker/Remote' server</description>"

# Create Debian 10 DNS/NTP Address Object
action "set" "Debian 10 DNS/NTP Address Object" "$addr_object_xpath[@name='debian-dns-ntp']" "<ip-netmask>172.20.240.20/24</ip-netmask><description>IPv4 address for the 'Debian 10 DNS/NTP' server</description>"

# Create Debian 10 DNS/NTP NAT Address Object
action "set" "Debian 10 DNS/NTP NAT Address Object" "$addr_object_xpath[@name='debian-dns-ntp-nat']" "<ip-netmask>172.25.$third_octet.20/24</ip-netmask><description>NAT IPv4 address for the 'Debian 10 DNS/NTP' server</description>"

# Create 2019 AD/DNS/DHCP Address Object
action "set" "2019 AD/DNS/DHCP Address Object" "$addr_object_xpath[@name='windows-server-2019']" "<ip-netmask>172.20.242.200/24</ip-netmask><description>IPv4 address for the 'Windows Server 2019 AD/DNS/DHCP' server</description>"

# Create 2019 AD/DNS/DHCP NAT Address Object
action "set" "2019 AD/DNS/DHCP NAT Address Object" "$addr_object_xpath[@name='windows-server-2019-nat']" "<ip-netmask>172.25.$third_octet.27/24</ip-netmask><description>NAT IPv4 address for the 'Windows Server 2019 AD/DNS/DHCP' server</description>"

# Create Fedora 21 Webmail/WebApps Address Object
action "set" "Fedora 21 Webmail/WebApps Address Object" "$addr_object_xpath[@name='fedora-webmail']" "<ip-netmask>172.20.241.40/24</ip-netmask><description>IPv4 address for the 'Fedora 21 Webmail/WebApps' server</description>"

# Create Fedora 21 Webmail/WebApps NAT Address Object
action "set" "Fedora 21 Webmail/WebApps NAT Address Object" "$addr_object_xpath[@name='fedora-webmail-nat']" "<ip-netmask>172.25.$third_octet.39/24</ip-netmask><description>NAT IPv4 address for the 'Fedora 21 Webmail/WebApps' server</description>"

# Create Splunk 9.1.1 Address Object
action "set" "Splunk 9.1.1 Address Object" "$addr_object_xpath[@name='splunk']" "<ip-netmask>172.20.241.20/24</ip-netmask><description>IPv4 address for the 'Splunk 9.1.1' server</description>"

# Create Splunk 9.1.1 NAT Address Object
action "set" "Splunk 9.1.1 NAT Address Object" "$addr_object_xpath[@name='splunk-nat']" "<ip-netmask>172.25.$third_octet.9/24</ip-netmask><description>NAT IPv4 address for the 'Splunk 9.1.1' server</description>"

# Create Ubuntu 18 Webserver Address Object
action "set" "Ubuntu 18 Webserver Address Object" "$addr_object_xpath[@name='ubuntu-web']" "<ip-netmask>172.20.242.10/24</ip-netmask><description>IPv4 address for the 'Ubuntu 18 Web' server</description>"

# Create Ubuntu 18 Webserver NAT Address Object
action "set" "Ubuntu 18 Webserver NAT Address Object" "$addr_object_xpath[@name='ubuntu-web-nat']" "<ip-netmask>172.25.$third_octet.23/24</ip-netmask><description>NAT IPv4 address for the 'Ubuntu 18 Web' server</description>"

# Create CentOS 7 E-Commerce Address Object
action "set" "CentOS 7 E-Commerce Address Object" "$addr_object_xpath[@name='centos-ecomm']" "<ip-netmask>172.20.241.30/24</ip-netmask><description>IPv4 Address for the 'CentOS 7 E-Commerce' server</description>"

# Create CentOS 7 E-Commerce NAT Address Object
action "set" "CentOS 7 E-Commerce NAT Address Object" "$addr_object_xpath[@name='centos-ecomm-nat']" "<ip-netmask>172.25.$third_octet.11/24</ip-netmask><description>NAT IPv4 Address for the 'CentOS 7 E-Commerce' server</description>"

# Create Blacklist Group
action "set" "Blacklist Address Group" "$addr_group_xpath[@name='blacklist']" "<static><member>placeholder</member></static>"

# Create GUI Address Group
action "set" "GUI Address Group" "$addr_group_xpath[@name='guis']" "<static><member>windows-server-2019</member><member>debian-dns-ntp</member><member>docker-remote</member></static>"

# Create SNMP Server Address Group
action "set" "SNMP Server Address Group" "$addr_group_xpath[@name='snmp-server']" "<static><member>placeholder</member></static>"

# Create All Company Servers Address Group
action "set" "All Company Servers Address Group" "$addr_group_xpath[@name='all-company-servers']" "<static><member>docker-remote</member><member>debian-dns-ntp</member><member>ubuntu-web</member><member>windows-server-2019</member><member>splunk</member><member>centos-ecomm</member><member>fedora-webmail</member><member>user-network-segment</member></static>"

# Create Internal Network Servers Address Group
action "set" "Internal Network Servers Address Group" "$addr_group_xpath[@name='internal-network-servers']" "<static><member>docker-remote</member><member>debian-dns-ntp</member></static>"

# Create Internal Network Servers NAT Address Group
action "set" "Internal Network Servers NAT Address Group" "$addr_group_xpath[@name='internal-network-servers-nat']" "<static><member>docker-remote-nat</member><member>debian-dns-ntp-nat</member></static>"

# Create User Network Servers Address Group
action "set" "User Network Servers Address Group" "$addr_group_xpath[@name='user-network-servers']" "<static><member>ubuntu-web</member><member>windows-server-2019</member></static>"

# Create User Network Servers NAT Address Group
action "set" "User Network Servers NAT Address Group" "$addr_group_xpath[@name='user-network-servers-nat']" "<static><member>ubuntu-web-nat</member><member>windows-server-2019-nat</member></static>"

# Create Public Network Servers Address Group
action "set" "Public Network Servers Address Group" "$addr_group_xpath[@name='public-network-servers']" "<static><member>splunk</member><member>centos-ecomm</member><member>fedora-webmail</member></static>"

# Create Public Network Servers NAT Address Group
action "set" "Public Network Servers NAT Address Group" "$addr_group_xpath[@name='public-network-servers-nat']" "<static><member>splunk-nat</member><member>centos-ecomm-nat</member><member>fedora-webmail-nat</member></static>"

# Create DNS Servers Address Group
action "set" "DNS Servers Address Group" "$addr_group_xpath[@name='dns-servers']" "<static><member>debian-dns-ntp</member><member>windows-server-2019</member></static>"

# Create DNS Servers NAT Address Group
action "set" "DNS Servers NAT Address Group" "$addr_group_xpath[@name='dns-servers-nat']" "<static><member>debian-dns-ntp-nat</member><member>windows-server-2019-nat</member></static>"

# Create NTP Servers Address Group
action "set" "NTP Servers Address Group" "$addr_group_xpath[@name='ntp-servers']" "<static><member>debian-dns-ntp</member></static>"

# Create Splunk 'Web Service' Object
action "set" "Splunk 'Web Service' Object" "$srvc_object_xpath[@name='splunk-web-service']" "<protocol><tcp><port>8000</port><override><no/></override></tcp></protocol><description>Splunk Web UI Service</description>"

# Create Splunk 'Management Service' Object
action "set" "Splunk 'Management Service' Object" "$srvc_object_xpath[@name='splunk-management-service']" "<protocol><tcp><port>8089</port><override><no/></override></tcp></protocol><description>Splunk Management Service</description>"

# Create Splunk 'Indexing Service' Object
action "set" "Splunk 'Indexing Service' Object" "$srvc_object_xpath[@name='splunk-indexing-service']" "<protocol><tcp><port>9997</port><override><no/></override></tcp></protocol><description>Splunk Indexing Service</description>"

# Create Splunk 'Index Replication Service' Object
action "set" "Splunk 'Index Replication Service' Object" "$srvc_object_xpath[@name='splunk-index-replication-service']" "<protocol><tcp><port>8080</port><override><no/></override></tcp></protocol><description>Splunk Index Replication Service</description>"

# Create Splunk 'Syslog Service' Object
action "set" "Splunk 'Syslog Service' Object" "$srvc_object_xpath[@name='splunk-syslog-service']" "<protocol><tcp><port>514</port><override><no/></override></tcp></protocol><description>Splunk Syslog Service</description>"

# Create Splunk Services Group
action "set" "Splunk Services Group" "$srvc_group_xpath[@name='splunk-services']" "<members><member>splunk-web-service</member><member>splunk-management-service</member><member>splunk-indexing-service</member><member>splunk-index-replication-service</member><member>splunk-syslog-service</member></members>"

# Create Splunk Syslog Profile
action "set" "Splunk Syslog Profile" "/config/shared/log-settings/syslog/entry[@name='syslog-server-profile']" "<server><entry name=\"splunk-server\"><transport>TCP</transport><port>1738</port><format>BSD</format><server>172.20.241.20</server><facility>LOG_USER</facility></entry></server>"

# Create Splunk Log Forwarding Profile
action "set" "Splunk Log Forwarding Profile" "$log_profiles_xpath/[@name='Splunk Log Forwarding']" "<match-list><entry name=\"splunk-syslog-auth\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all auth logs and forward them using the splunk syslog profile</action-desc><log-type>auth</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-data\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all data logs and forward them using the splunk syslog profile</action-desc><log-type>data</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-decryption\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all decryption logs and forward them using the splunk syslog profile</action-desc><log-type>decryption</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-threat\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all threat logs and forward them using the splunk syslog profile</action-desc><log-type>threat</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-tunnel\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all tunnel logs and forward them using the splunk syslog profile</action-desc><log-type>tunnel</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-url\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all url logs and forward them using the splunk syslog profile</action-desc><log-type>url</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry><entry name=\"splunk-syslog-wildfire\"><send-syslog><member>Splunk Syslog Profile</member></send-syslog><action-desc>Match all wildfire logs and forward them using the splunk syslog profile</action-desc><log-type>wildfire</log-type><filter>All Logs</filter><send-to-panorama>no</send-to-panorama></entry></match-list><description>Log profile for the splunk server</description>"




exit 0 # Script ended successfully
