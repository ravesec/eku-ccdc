#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
touch /var/log/gemini.log
mv $repo_root/scripts/linux/Gemini/localGemini /etc/gemini/monitor.py
chmod +x /etc/gemini/monitor.py
cat <<EOFA > /etc/systemd/system/gemini.service
[Unit]
Description=Gemini system integrity service

[Service]
Type=simple
Restart=on-failure
Environment="PATH=/sbin:/bin:/usr/sbin:/usr/bin"
ExecStart=/bin/bash -c '/etc/gemini/monitor.py'
StartLimitInterval=1s
StartLimitBurst=999

[Install]
WantedBy=multi-user.target
EOFA
systemctl daemon-reload
systemctl enable gemini
systemctl start gemini
rm $0