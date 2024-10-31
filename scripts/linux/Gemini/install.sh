#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
mkdir /.quarantine
chmod 400 /.quarantine/
touch /var/log/gemini.log
mv $repo_root/scripts/linux/Gemini/localGemini.py /etc/gemini/monitor.py
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
echo "Gemini installed, but has not started. Please edit the file located at /etc/gemini/monitor.py and make changes to the settings as needed before starting."
echo "Once settings have been changed, start Gemini by running these two commands:"
echo "systemctl enable gemini.service"
echo "systemctl start gemini.service"
rm $0