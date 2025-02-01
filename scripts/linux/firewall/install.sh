#!/bin/bash
if [ $EUID -ne 0 ]; then
    echo "Must be run as root"
	exit
fi
repo_root=$(git rev-parse --show-toplevel)
yum install -y nftables
apt install -y nftables
if [[ -f /bin/nft || -f /sbin/nft ]]; then
	rawVersion=$(nft --version)
	IFS=" " read -ra versionSplit <<< "$rawVersion"
	version="${versionSplit[1]}"
	version="${version:1}"
	if ! [[ "${version:0:1}" == "1" ]]; then
		numVersion=$(echo "$version" | bc)
		if (( $(echo "$numVersion < 0.5" | bc -l) )); then
			echo "This machine is unable to support nftables version 0.5 or higher. Installing firewall using iptables."
			bash $repo_root/scripts/linux/firewall/ipTablesFirewall/setup.sh
			exit
		fi
	fi
else
	echo "This machine is unable to support nftables. Installing firewall using iptables."
	bash $repo_root/scripts/linux/firewall/ipTablesFirewall/setup.sh
	exit
fi
yum install -y python3
apt install -y python3
if [[ -f /bin/python3 ]]; then
	rawVersion=$(python3 -V)
	IFS=" " read -ra versionSplit <<< "$rawVersion"
	version="${versionSplit[1]}"
	IFS="." read -ra versionSplit <<< "$version"
	firstNum=$((${versionSplit[0]}))
	secondNum=$((${versionSplit[1]}))
	if [[ $firstNum -lt 3 ]]; then
		echo "This machine is unable to support python3. Installing firewall using iptables."
		bash $repo_root/scripts/linux/firewall/ipTablesFirewall/setup.sh
		exit
	elif [[ $secondNum -lt 8 ]]; then
		echo "This machine is unable to support python 3.8. Installing firewall using iptables."
		bash $repo_root/scripts/linux/firewall/ipTablesFirewall/setup.sh
		exit
	fi
else
	echo "This machine is unable to support python3. Installing firewall using iptables."
	bash $repo_root/scripts/linux/firewall/ipTablesFirewall/setup.sh
	exit
fi
echo "This machine passes all dependency checks. Installing firewaill using nftables."
bash $repo_root/scripts/linux/firewall/nfTablesFirewall/setup.sh