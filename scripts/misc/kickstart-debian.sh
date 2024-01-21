#!/bin/bash

add_user () {
	
	if [[ $EUID > 0 ]]
	then
  		echo "This function requires root!"
  		exit
	fi

	if [[ -z "$1" ]]
	then
		echo "No user specified!"
		exit
	else
		echo "Creating user..."
		useradd --create-home --user-group --shell $(which bash) $1
	fi
	echo "Operation add user $1 complete. Be sure to set the user's password accordingly."
}

add_root_user() {

	if [[ $EUID > 0 ]]
	then
  	 	echo "This function requires root!"
  	 	exit
	fi

	if [[ -z "$1" ]]
	then
		echo "No user specified!"
		exit
	else
		echo "Creating root user..."
		useradd --create-home --user-group --shell $(which bash) $1
		usermod -aG sudo $1
	fi
	echo "Operation add root user $1 complete. Be sure to set the user's password accordingly."
}

set_hostname() {

	if [[ $EUID > 0 ]]
	then
  		echo "This function requires root!"
  		exit
	fi

	if [[ -z "$1" ]]
	then
		echo "No hostname specified!"
		exit
	else
		echo "Setting hostname to $1..."
		printf "%s\n%s\n%s\n\n%s\n%s\n%s\n%s\n" "#/etc/hosts" "127.0.0.1	localhost" "127.0.0.1       $1" "# The following lines are desirable for IPv6 capable hosts" "::1             localhost ip6-localhost ip6-loopback" "ff02::1         ip6-allnodes" "ff02::2         ip6-allrouters" > /etc/hosts
		echo "/etc/hosts modified."
		echo "$1" > /etc/hostname
		echo "/etc/hostname modified."
	fi
}

install_base() {
	
	if [[ $EUID > 0 ]]
	then
  		echo "Script must be ran as root!"
  		exit
	fi

	echo "Updating repositories and installing base packages..."
	apt update
	apt upgrade -y
	apt install -y sudo vim binutils inetutils-* net-tools htop btop mtr curl wget git ufw zsh tcpdump build-essential dnsutils nmap tcpdump tmux unattended-upgrades software-properties-common
}

config_zsh() {
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	echo "Downloading zsh config files..."
	cd ~
	wget http://ravenn.net/zsh_conf.tar && tar -xvf zsh_conf.tar && rm zsh_conf.tar
}

config_ufw() {

	if [[ $EUID > 0 ]]
	then
  		echo "Script must be ran as root!"
  		exit
	fi

	echo "Configuring ufw..."
	ufw default deny
	ufw logging low
	ufw allow proto tcp from any to any port 22
	ufw --force enable
}

customize() {
	echo "Downloading tmux config files..."
	cd ~
	wget http://ravenn.net/tmux_conf.tar && tar -xvf tmux_conf.tar && rm tmux_conf.tar
	#echo 'alias tmux="TERM=screen-256color-bce tmux"' >> .zshrc
	#echo 'alias tmux=TERM=screen-256color-bce tmux' >> .bashrc
	echo "Downloading vim config files..."
	wget http://ravenn.net/vim_conf.tar && tar -xvf vim_conf.tar && rm vim_conf.tar
	echo "Configuration completed successfully!"
}

usage() { echo "Usage: [-h] [-u <user>] [-r <priv_user>] [-b] [-f] [-n <hostname>] [-z] [-c]" 1>&2; exit 1; }

help() {
	echo
	echo "Options:"
	echo "-h, --help		Display this help page."
	echo "-u, --add-user		Create an unprivleged user."
	echo "-r, --add-root-user	Create a root user."
	echo "-b, --install-base	Update current packages and install base packages."
	echo "-f, --firewall		Enable UFW with port 22 open, default drop, and low logging."
	echo "-n, --hostname		Change system hostname."
	echo "-z, --omz			Install and Configure ZSH."
	echo "-c, --config		Install custom configuration for vim and tmux."
	echo
}

#if [[ $EUID > 0 ]]
#then
#  echo "Script must be ran as root!"
#  exit
#fi

while [[ $# -gt 0 ]]; do
	case $1 in
		-h | --help)# Display help
			help
			exit;;
		-u | --add-user)# Add unprivileged user
			add_user $2;;
		-b | --install-base) # Install base packages
			install_base
			;;
		-r | --add-root-user)# Add root user
			add_root_user $2;;
		-f | --firewall)# Configure UFW
			config_ufw;;
		-n | --hostname)# Configure system hostname
			set_hostname $2;;
		-z | --omz)# Config ZSH
			config_zsh;;
		-c | --config)# Installl custom config for tmux and vim
			customize;;
	esac
	shift
done
		   
exit
