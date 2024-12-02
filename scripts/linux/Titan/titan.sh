#!/bin/bash
TMP_FILE="/tmp/dir_busting.tmp"
PATTERN="404|DirBuster|Gobuster"

touch "$TMP_FILE"
getFileContAsStr()
{
	local fileName="$1"
	local -n fileCont="$2"
	if [[ ! -f "$fileName" ]]; then
        fileCont=""
	else
		fileCont=$(<"$fileName")
    fi
}
sendLog()
{
	newLog="[ $machineName ] - $log"
	echo $newLog | nc 172.20.241.20 1973
	sleep 0.1
}
processConfFile()
{
	mapfile -t confList < "/etc/titan/titan.conf"
	for line in "${confList[@]}"; do
		if ! [[ "${line:0:1}" == "#" ]]; then
			IFS="=" read -ra lineSplit <<< "$line"
			case "${lineSplit[0]}" in
				"web_server_access.log")
					webServerAccessLog="${lineSplit[1]}"
					;;
				*)
					;;
			esac
		fi
	done
}
getFileContAsStr /etc/gemini/machine.name machineName
processConfFile
while true; do
    NEW_ENTRIES=$(comm -13 <(sort "$TMP_FILE") <(sort "$webServerAccessLog"))

    echo "$NEW_ENTRIES" | grep -E "$PATTERN" | while read -r line; do
        echo "$line" >> "$TMP_FILE"

        IP=$(echo "$line" | awk '{print $1}')

        current_time=$(date +"%H:%M:%S")
		log="[ $current_time ] - Detected potential directory busting from $IP"
		echo $log >> /var/log/gemini.log
		sendLog
    done

    echo "$NEW_ENTRIES" >> "$TMP_FILE"

    sleep 5
done