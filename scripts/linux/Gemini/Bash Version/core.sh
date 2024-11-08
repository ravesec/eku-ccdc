#!/bin/bash
whitelistUsers=("root","sysadmin","sshd","sync","_apt","nobody")
getFileCont() #usage: "getFileCont {file name} {array variable name}"
{
	local fileName="$1"
	local -n arr="$2"
	if [[ ! -f "$fileName" ]]; then
		return 1
	fi
	mapfile -t arr < "$fileName"
}
userInWhitelist() 
{
    local user="$1"
	local -n result="$2"
	result="4"
    for entry in "${whitelistUsers[@]}"; do
        if [[ "$entry" == "$user" ]]; then
            result="2"
        fi
    done
    if [[ ! $result -eq "2" ]]; then
		result="3"
	fi
}
while true; do
getFileCont "/etc/passwd" passwdConts
for line in "${passwdConts[@]}"; do
	IFS=":" read -ra userInfo <<< "$line"
	username=${userInfo[0]}
    declare -i uid=${userInfo[2]}
    declare -i gid=${userInfo[3]}
	userInWhitelist $username isInWhitelist
	if [[ $uid -gt 999 || $gid -gt 999 ]] && [[ $isInWhitelist -eq "3" ]]; then
		userdel -f $username
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - An unknown user with UID/GID above 999 was found and removed: $username"
		echo $log >> /var/log/gemini.log
	fi
isInWhitelist=""
done
sleep 60
done