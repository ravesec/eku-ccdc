#!/bin/bash
echo "Clearing splunk and installing new admin user..."
/opt/splunk/bin/stop
/opt/splunk/bin/splunk clean all -f
echo "stty -echo"
echo "Enter new splunk admin password: "
read password
cat <<EOFA > /opt/splunk/etc/system/local/user-seed.conf
[user_info]
USERNAME = admin
PASSOWRD = $password
EOFA
echo "stty echo"
/opt/splunk/bin/start
echo "Splunk accounts reset."
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc/eku-ccdc
fi
echo "Moving Manticore..."
mkdir /etc/manticore
mv /etc/eku-ccdc/scripts/linux/Manticore/* /etc/manticore
rm /etc/manticore/setup.sh
echo "Preventing password changes..."
chattr +i /etc/passwd
chattr +i /opt/splunk/etc/passwd
cat <<EOFA > /etc/manticore/listenerSetup
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc/eku-ccdc
fi
mv /etc/eku-ccdc/scripts/linux/Manticore/listener.py /bin/manticoreListener
chmod +x /bin/manticoreListener
manticoreListener "1893" &
cat << EOFB > /etc/systemd/system/manticore.service
[Unit]
Description=Manticore listener service

[Service]
Type=forking
Environment="PATH=/sbin:/bin:/usr/sbin:/usr/bin"
ExecStart=/bin/bash -c 'manticoreListener "1893"'
StartLimitInterval=1s
StartLimitBurst=999

[Install]
WantedBy=multi-user.target
EOFB
rm /tmp/manticoreSetup
EOFA
echo "Setting up E-Comm listener..."
python3 /etc/manticore/netListenerSetup.py "172.20.241.30"
echo "Setting up Fedora listener..."
python3 /etc/manticore/netListenerSetup.py "172.20.241.40"
#echo "Setting up Debian listener..."
#echo "Setting up Ubuntu listener..."
echo "Setting up firewall..."
mv /etc/eku-ccdc/scripts/linux/nfTablesFirewall/firewall.py /bin/firewall
chmod +x /bin/firewall
echo "Defaults env_keep += \"SSH_CONNECTION SSH_CLIENT SSH_TTY\"" >> /etc/sudoers
python3 /etc/eku-ccdc/scripts/linux/nfTablesFirewall/setup.py "splunk"