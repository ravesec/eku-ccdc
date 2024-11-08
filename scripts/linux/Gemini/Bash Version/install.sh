#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
mkdir /etc/gemini
mv "$repo_root/scripts/linux/Gemini/Bash Version/core.sh" /etc/gemini/core
chmod +x /etc/gemini/core
mv "$repo_root/scripts/linux/Gemini/Bash Version/gemini.service" /etc/systemd/system/gemini.service
systemctl daemon-reload
systemctl enable gemini
systemctl start gemini