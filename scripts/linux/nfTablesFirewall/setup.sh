#!/bin/bash
apt-get update && apt-get install -y nftables 
apt-get update && apt-get install -y python3 
yum install -y nftables 
yum install -y python3 
mv /etc/eku-ccdc/scripts/linux/nfTablesFirewall/firewall.py /etc/firewall.py
mv /etc/eku-ccdc/scripts/linux/nfTablesFirewall/firewall.sh /bin/firewall
chmod +x /bin/firewall
echo "Defaults env_keep += \"SSH_CONNECTION SSH_CLIENT SSH_TTY\"" >> /etc/sudoers
python3 /etc/eku-ccdc/scripts/linux/nfTablesFirewall/setup.py
rm $0