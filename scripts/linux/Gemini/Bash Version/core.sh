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
    for entry in "${whitelistUsers[@]}"; do
        if [[ "$entry" == "$user" ]]; then
            return 0
        fi
    done
    return 1
}
while true; do
getFileCont "/etc/passwd" passwdConts
for line in "${passwdConts[@]}"; do
	IFS=":" read -ra userInfo <<< "$line"
	username=${userInfo[0]}
    declare -i uid=${userInfo[2]}
    declare -i gid=${userInfo[3]}
	if [[ $uid -gt 999 || $gid -gt 999 ]] && [[ ! userInWhitelist $username ]]; then
		userdel -f $username
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - An unknown user with UID/GID above 999 was found and removed: $username"
		echo $log >> /var/log/gemini.log
	fi

done
sleep 60
done