#!/bin/bash
whitelistUsers=("root" "sysadmin" "sshd" "sync" "_apt" "nobody")
suspiciousFileNames=("shell.php" "template.php")
getFileContAsArray() #usage: "getFileCont {file name} {array variable name}"
{
	local fileName="$1"
	local -n arr="$2"
	if [[ ! -f "$fileName" ]]; then
		return 1
	fi
	mapfile -t arr < "$fileName"
}
getFileContAsStr()
{
	local fileName="$1"
	local -n fileCont="$2"
	if [[ ! -f "$fileName" ]]; then
        fileCont=""
	else
		fileCont=$(<"$fileName")
    fi
    echo "$fileCont"
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
    if [[ ! $result == "2" ]]; then
		result="3"
	fi
}
while true; do
#Checking for unknown users
getFileContAsArray "/etc/passwd" passwdConts
for line in "${passwdConts[@]}"; do
	IFS=":" read -ra userInfo <<< "$line"
	username=${userInfo[0]}
    declare -i uid=${userInfo[2]}
    declare -i gid=${userInfo[3]}
	userInWhitelist $username isInWhitelist
	if [[ $uid -gt 999 || $gid -gt 999 ]] && [[ $isInWhitelist == "3" ]]; then
		userdel -f $username
		current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - An unknown user with UID/GID above 999 was found and removed: $username"
		echo $log >> /var/log/gemini.log
	fi
isInWhitelist=""
done
#Checking for malicious services

#Checking for crontab changes
getFileContAsStr "/etc/crontab" crontabCont
if [[ ! $crontabCont == "\n" ]]; then
	echo "" > /etc/crontab
	current_time=$(date +"%H:%M:%S")
	log="[ $current_time ] - Changes were detected in /etc/crontab and removed: $crontabCont"
	echo $log >> /var/log/gemini.log
fi
#Checking for common reverse shell practices

#Checking for remote logins

#Checking for suspicious files in a webserver

sleep 60
done