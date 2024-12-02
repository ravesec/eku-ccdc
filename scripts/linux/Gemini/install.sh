#!/bin/bash
yum install -y nc
apt install -y nc
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
mkdir /.quarantine
mv "$repo_root/scripts/linux/Gemini/core.sh" /etc/gemini/core
chmod +x /etc/gemini/core
mv "$repo_root/scripts/linux/Gemini/gemini.service" /etc/systemd/system/gemini.service
systemctl daemon-reload
if [[ -d /var/www/ ]]; then
	echo "Webserver detected, installing Titan Web-Guard."
	bash $repo_root/scripts/linux/Titan/install.sh
fi
if [[ -z "$1" ]]; then
	declare -i x=3
	machineList=("centos" "ecom" "fedora" "debian" "ubuntu")
	while [[ x -eq 3 ]]; do
		echo "Enter your machine name(centos/fedora/debian/ubuntu): "
		read machine
		for item in "${machineList[@]}"; do
			if [[ $machine == $item ]]; then
				x=4
			fi
		done
		if [[ x -eq 3 ]]; then
			echo "Invalid entry."
		fi
	done
	touch /etc/gemini/machine.name
	echo "$machine" >> machine.name
	echo "Gemini installed, but has not started. Please edit the file located at /etc/gemini/core.sh and make changes to the settings as needed before starting."
	echo "Once settings have been changed, start Gemini by running these two commands:"
	echo "systemctl enable gemini.service"
	echo "systemctl start gemini.service"
elif [[ "$1" == "-s" ]]; then
    mv "$repo_root/scripts/linux/Gemini/splCore.sh" /etc/gemini/core
	chmod +x /etc/gemini/core
	touch /etc/gemini/buffer.lo
	touch /etc/gemini/read.log
	touch /etc/gemini/active.log
	touch /var/log/masterGemini.log
	mv $repo_root/scripts/linux/Gemini/listener.sh /etc/gemini/listener
	chmod +x /etc/gemini/listener
	mv $repo_root/scripts/linux/Gemini/geminiListener.service /etc/systemd/system/geminiListener.service
	systemctl daemon-reload
	systemctl enable geminiListener
	systemctl start geminiListener
	echo "Gemini installed, but has not started. Please edit the file located at /etc/gemini/core.sh and make changes to the settings as needed before starting."
	echo "Once settings have been changed, start Gemini by running these two commands:"
	echo "systemctl enable gemini.service"
	echo "systemctl start gemini.service"
fi