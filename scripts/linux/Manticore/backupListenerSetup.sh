#!/bin/bash
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc/eku-ccdc
fi
mv /etc/eku-ccdc/scripts/linux/Manticore/listener.py /bin/manticoreListener
chmod +x /bin/manticoreListener
cat << EOFB > /etc/systemd/system/manticore.service
[Unit]
Description=Manticore listener service

[Service]
Type=simple
Restart=on-failure
Environment="PATH=/sbin:/bin:/usr/sbin:/usr/bin"
ExecStart=/bin/bash -c 'manticoreListener "1893"'
StartLimitInterval=1s
StartLimitBurst=999

[Install]
WantedBy=multi-user.target
EOFB
systemctl enable manticore
systemctl start manticore
rm $0