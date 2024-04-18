#!/bin/bash
machine=$1
if [ $machine=="centos" ]
then
cat <<EOFA > /etc/systemd/system/security.service
[Unit]
Description=Service used for splunk alert automation for EKU's CCDC team.

[Service]
Type=forking
Environment="PATH=/sbin:/bin:/usr/sbin:/usr/bin"
ExecStart=python3 /etc/secService.py centos
StartLimitInterval=1s
StartLimitBurst=999

[Install]
WantedBy=multi-user.target
EOFA
yum install -y python3
mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/secService.py /etc/secService.py
mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/security.sh /usr/bin/security
mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/security.py /usr/bin/security.py
systemctl daemon reload
systemctl enable security.service
systemctl start security.service
fi
if [ $machine=="debian" ]
then
apt-get update && apt-get install -y python3
echo "kdsajf;ds"
fi
if [ $machine=="fedora" ]
then
yum install -y python3
echo "dwehqfjek"
fi
if [ $machine=="ubuntu" ]
then
apt-get update && apt-get install -y python3
echo "dswqgudhq"
fi