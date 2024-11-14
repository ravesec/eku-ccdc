#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
mkdir /.quarantine
mv "$repo_root/scripts/linux/Gemini/Bash Version/core.sh" /etc/gemini/core
chmod +x /etc/gemini/core
mv "$repo_root/scripts/linux/Gemini/Bash Version/gemini.service" /etc/systemd/system/gemini.service
systemctl daemon-reload
declare -i x=3
machineList=("centos" "ecom" "fedora" "debian" "ubuntu")
while [[ x -eq 3 ]]; do
	echo "Enter your machine name(centos/fedora/debian/ubuntu): "
	read machine
	for item in "${machineList[@]}"); do
		if [[ machine == item ]]; then
			$x=4
		fi
	done
	if [[ x -eq 3 ]]; then
		echo "Invalid entry."
	fi
done
touch /etc/gemini/machine.name
echo $machine >> machine.name
if [[ ! -z "$1" ]] && [[ ! "$1" == "-s" ]]; then
	echo "Gemini installed, but has not started. Please edit the file located at /etc/gemini/core.sh and make changes to the settings as needed before starting."
	echo "Once settings have been changed, start Gemini by running these two commands:"
	echo "systemctl enable gemini.service"
	echo "systemctl start gemini.service"
else
    mv "$repo_root/scripts/linux/Gemini/Bash Version/splCore.sh" /etc/gemini/core
	touch /etc/gemini/buffer.log
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