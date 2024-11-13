#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
mv "$repo_root/scripts/linux/Gemini/Bash Version/core.sh" /etc/gemini/core
chmod +x /etc/gemini/core
mv "$repo_root/scripts/linux/Gemini/Bash Version/gemini.service" /etc/systemd/system/gemini.service
systemctl daemon-reload
echo "Gemini installed, but has not started. Please edit the file located at /etc/gemini/core.sh and make changes to the settings as needed before starting."
echo "Once settings have been changed, start Gemini by running these two commands:"
echo "systemctl enable gemini.service"
echo "systemctl start gemini.service"