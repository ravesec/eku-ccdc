#!/bin/bash
# NOTE: Manticore port shows as "elad", Arbiter port shows as "dslrap"
if [ $EUID -ne 0 ]; then
    echo "Must be run as root"
	exit
fi
addToBlacklist() #Usage: addToBlacklist {ip}
{
	local blacklistIP="$1"
	
	iptables -A INPUT -s $blacklistIP -j DROP
	iptables -A OUTPUT -d $blacklistIP -j DROP
}
removeFromBlacklist() #Usage: removeFromBlacklist {ip}
{
	local blacklistIP="$1"
}
addToWhitelist() #Usage: addToWhitelist {ip}
{
	local whitelistIP="$1"
	
	iptables -A INPUT -s $whitelistIP -j ACCEPT
	iptables -A OUTPUT -d $whitelistIP -j ACCEPT
}
removeFromWhitelist() #Usage: removeFromWhitelist {ip}
{
	local whitelistIP="$1"
}
getChainList() #Usage: getChainList {chain} {variable name to save array to} -> Returns a string. It will be length 0 if everything processes correctly.
{
	local validChains=("INPUT" "OUTPUT" "FORWARD" "input" "output" "forward")
	local chainName="$1"
	local isValid="false"
	for chain in "${validChains[@]}"; do
		if [[ "$chainName" == "$chain" ]]; then
			isValid="true"
		fi
	done
	if [[ "isValid" == "false" ]]; then
		echo "Invalid chain entry"
		exit
	fi
	case "$chainName" in
		"INPUT")
			chainName="INPUT"
		;;
		"input")
			chainName="INPUT"
		;;
		"OUTPUT")
			chainName="OUTPUT"
		;;
		"output")
			chainName="OUTPUT"
		;;
		"FORWARD")
			chainName="FORWARD"
		;;
		"forward")
			chainName="FORWARD"
		;;
		*)
			echo "An error occured in chain name translation."
			exit
		;;
	esac
	local targetChainStartIndex=$((-1))
	local fullChainList=$(iptables -L --line-numbers)
	mapfile -t fullChainListSplit <<< "$fullChainList"
	local num=$((0))
	local currentLine=""
	while [ "$num" -lt "${#fullChainListSplit[@]}" ]; do
		currentLine="${fullChainListSplit[$num]}"
		if ! [[ ${#currentLine} -eq 0 ]]; then
			IFS=" " read -ra currentLineSplit <<< "$currentLine"
			if [[ "${currentLineSplit[0]}" == "Chain" ]] && [[ "${currentLineSplit[1]}" == "$chainName" ]]; then
				targetChainStartIndex=$num
			fi
		fi
		((num=$num+1))
	done
	num=$(($targetChainStartIndex+1))
	while [ "$num" -lt "${#fullChainListSplit[@]}" ]; do
		currentLine="${fullChainListSplit[$num]}"
		if ! [[ ${#currentLine} -eq 0 ]]; then
			IFS=" " read -ra currentLineSplit <<< "$currentLine"
			if [[ "${currentLineSplit[0]}" -eq "Chain" ]]; then
				local targetChainEndIndex=$(($num-1))
			fi
		fi
		((num=$num+1))
	done
	if ! [[ $targetChainEndIndex -gt 0 ]]; then
		targetChainEndIndex=$((${#fullChainListSplit[@]}))
	fi
	if [[ $targetChainEndIndex -lt $targetChainStartIndex ]]; then
		echo "An error occured in finding the selected chain's boundaries"
		exit
	fi
	num=$targetChainStartIndex
	local -n returnArray="$2"
	returnArray=()
	while [ $num -lt $targetChainEndIndex ]; do
		currentLine="${fullChainListSplit[$num]}"
		if ! [[ ${#currentLine} -eq 0 ]]; then
			returnArray+=("$currentLine")
		fi
		((num=$num+1))
	done
}
