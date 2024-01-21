#!/bin/bash

# Horizontal is a Vertical Line
# Vertical is a Horizontal Line

# Define var names for easier typing
session='CCDC'
LOGS=0
AV=1
RKHUNTER=2
SCANNER=3
SNIFFER_EXT=4
SNIFFER_INT=5
FILES=6
CONSOLE_1=7
CONSOLE_2=8
SSH_1=9
SSH_2=10

PANE_JRNL=0
PANE_INTG=1
PANE_CRON=2
PANE_FRSH=0
PANE_AVSC=1
PANE_RKSC=0
PANE_RKLG=1
PANE_BACK=0
PANE_REST=1
PANE_FCON=2

# Creates a new session named "CCDC" and detaches from it
tmux new-session -d -s $session

# Creates Workspace Structure
tmux rename-window -t $session:$LOGS 'LOGS'
tmux new-window -t $session:$AV -n 'AV'
tmux new-window -t $session:$RKHUNTER -n 'RKHUNTER'
tmux new-window -t $session:$SCANNER -n 'SCANNER'
tmux new-window -t $session:$SNIFFER_EXT -n 'ESNIFF'
tmux new-window -t $session:$SNIFFER_INT -n 'ISNIFF'
tmux new-window -t $session:$FILES -n 'FILES'
tmux new-window -t $session:$CONSOLE_1 -n 'CON1'
tmux new-window -t $session:$CONSOLE_2 -n 'CON2'
tmux new-window -t $session:$SSH_1 -n 'SSH1'
tmux new-window -t $session:$SSH_2 -n 'SSH2'

# Workspace Setup

#
# Logging Window Setup
#

# Partition the Logs Window
tmux split-window -v -t $session:$LOGS
tmux split-window -h -t $session:$LOGS.$PANE_INTG

# Monitor/Follow the journalctl
tmux send-keys -t $session:$LOGS.$PANE_JRNL 'sudo journalctl -f' Enter

# Monitor the integrity logging cronjob
tmux send-keys -t $session:$LOGS.$PANE_INTG 'sudo tail -f /var/log/checksums.log'

# Monitor the cron edits cronjob
tmux send-keys -t $session:$LOGS.$PANE_CRON 'sudo tail -f /var/log/cron_edits.log'


#
# Antivirus Window Setup
#

# Paritition the Antivirus Window
tmux split-window -h -t $session:$AV

# Update the virus signature DB
tmux send-keys -t $session:$AV.$FRSH 'sudo freshclam'

# Prepare the command to run the AV scan
tmux send-keys -t $session:$AV.$AVSC 'echo "Only start the scan when freshclam has finished!!!"' Enter
tmux send-keys -t $session:$AV.$AVSC 'sudo clamscan --verbose --infected --recursive /root /etc /opt /tmp /home /usr /var /boot'

#
# RKHunter Window Setup
#

# Paritition the RKHunter Window
tmux split-window -h -t $session:$RKHUNTER

# Start the RKHunter scan
tmux send-keys -t $session:$RKHUNTER.$RKSC 'sudo rkhunter --vl --check --skip-keypress --nomow --rwo'

# Monitor the RKHunter logs
tmux send-keys -t $session:$RKHUNTER.$RKLG 'tail -f /var/log/rkhunter.log'

#
# Scanner Setup
#

# Make and go-to Scanning Directory
tmux send-keys -t $session:$SCANNER 'mkdir /root/scans/ && cd /root/scans' Enter

# Start Internal Network Scan
tmux send-keys -t $session:$SCANNER 'sudo nmap -sC -sV -sU --min-rate 5000 -oA /root/scans/internal-scan -T5 -p- 172.20.240-242.0/24'

#
# Sniffer Setup
#

# Begin sniffing for traffic coming from external addresses only
tmux send-keys -t $session:$SNIFFER_EXT "sudo tcpdump -i 1 'not (src net 172.20.240.0/24 or src net 172.20.241.0/24 or src net 172.20.242.0/24)'"
# Begin sniffing for traffic originating from the company network only
tmux send-keys -t $session:$SNIFFER_INT "sudo tcpdump -i 1 'src net 172.20.240.0/24 or src net 172.20.241.0/24 or src net 172.20.242.0/24'"

#
# Files Setup (Backups, Restoration, and Secure Copies)
#

# Partition the Window
tmux split-window -h -t $session:$FILES.$PANE_BACK
tmux split-window -v -t $session:$FILES.$PANE_REST

# Create Backups
tmux send-keys -t $session:$FILES.$PANE_BACK 'echo backup command here'
tmux send-keys -t $session:$FILES.$PANE_REST 'echo restoration pane'

tmux a -t $session




