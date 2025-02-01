#This installer is designed to be used in conjunction with the EKU-CCDC github (https://github.com/ravesec/eku-ccdc)
#This can be run on any linux machine and it will begin installing the custom tools involved in the competition

#!/bin/bash
echo "Installing dependencies"
yum install -y nc iptables nft 
apt install -y nc iptables nft
repo_root=$(git rev-parse --show-toplevel)
echo "Installing Gemini EDR"
bash $repo_root/scripts/linux/Gemini/install.sh
echo "Installing Manticore Listener"
echo "NOT IMPLEMENTED" #when manticore is stable on old linux versions, execute the listener install
echo "Installing Arbiter Log Forwarder"
echo "NOT IMPLEMENTED" #when arbiter is functional, install the log forwarder
echo "Installing Inferno Firewall"
bash $repo_root/scripts/linux/firewall/install.sh
echo "Installation complete."
echo "Don't forget to edit the file located at /etc/Gemini/gemini.conf before starting Gemini."
echo "It can brick your service if you don't"
echo "When it's edited, run the following two commands:"
echo "systemctl enable gemini.service"
echo "systemctl start gemini.service"