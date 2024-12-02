#!/bin/bash
logFile="ERROR"
findLogFile()
{
	possLogFileLocations=("apache2" "httpd" "nginx")
	for item in "${possLogFileLocations[@]}"; do
		if [[ -f /var/log/$item/access.log ]] || [[ -f /var/log/$item/access_log ]]; then
			if [[ -f /var/log/$item/access.log ]]; then
				logFile="/var/log/$item/access.log"
			elif [[ -f /var/log/$item/access_log ]]; then
				logFile="/var/log/$item/access_log"
			fi
		fi
	done
}
yum install -y iptables
apt install -y iptables
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/titan
mv $repo_root/scripts/linux/Titan/titan.sh /etc/titan/core
chmod +x /etc/titan/core
mv $repo_root/scripts/linux/Titan/titan.service /etc/systemd/system/titan.service
findLogFile
if [[ "$logFile" == "ERROR" ]]; then
	echo "Error detecting access log, please manually add the access log path into /etc/titan/titan.conf"
fi
cat << EOFA > /etc/titan/titan.conf
# Titan Web-Guard Configuration File
#
#
# File for the web server's access.log file. Only change this variable if you decide to move the access.log file
web_server_access.log=$logFile
# 
EOFA
systemctl enable titan
systemctl start titan