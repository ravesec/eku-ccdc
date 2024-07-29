#!/bin/bash
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc
fi
echo "Moving Manticore..."
mkdir /etc/manticore
mv /etc/eku-ccdc/scripts/linux/Manticore/* /etc/manticore
rm /etc/manticore/setup.sh
echo "Setting up firewall..."
mv /etc/eku-ccdc/scripts/linux/nfTablesFirewall/firewall.py /bin/firewall
chmod +x /bin/firewall
echo "Defaults env_keep += \"SSH_CONNECTION SSH_CLIENT SSH_TTY\"" >> /etc/sudoers
python3 /etc/eku-ccdc/scripts/linux/nfTablesFirewall/setup.py "splunk"
echo "Preventing password changes..."
chattr +i /etc/passwd
chattr +i /opt/splunk/etc/passwd
echo "Setting up E-Comm listener..."
python3 /etc/manticore/netListenerSetup.py "172.20.241.30"
echo "Setting up Fedora listener..."
python3 /etc/manticore/netListenerSetup.py "172.20.241.40"
#echo "Setting up Debian listener..."
#echo "Setting up Ubuntu listener..."