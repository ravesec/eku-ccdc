#!/bin/bash
TMP_FILE="/tmp/dir_busting.tmp"
PATTERN="404|DirBuster|Gobuster"
suspiciousFileNames=("shell.php" "template.php")
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
findFiles() 
{
    local origin="$1"
    fileList=()
    while IFS= read -r file; do
        fileList+=("$file")
    done < <(find "$origin" -type f)
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
    done

    echo "$NEW_ENTRIES" >> "$TMP_FILE"

	findFiles "/var/www/"
	for file in "${fileList[@]}"; do
		for suspiciousFile in "${suspiciousFileNames[@]}"; do
			if [[ "$file" == "$suspiciousFile" ]]; then
				mv $file "/.quarantine/$suspiciousFile"
				current_time=$(date +"%H:%M:%S")
				log="[ $current_time ] - A suspicious file was detected in '/var/www' and was quarintined: $suspiciousFile"
				echo $log >> /var/log/gemini.log
			fi
		done
	done
    sleep 5
done