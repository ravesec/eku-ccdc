#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
touch /etc/gemini/buffer.log
touch /etc/gemini/read.log
touch /etc/gemini/active.log
touch /var/log/masterGemini.log
mv $repo_root/scripts/linux/Arbiter/terminal.py /bin/arbiter
chmod +x /bin/arbiter