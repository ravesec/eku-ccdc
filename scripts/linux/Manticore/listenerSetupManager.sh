#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
stty -echo
echo "Enter Ecom root password: "
read ecomPass
echo "Enter Fedora root password: "
read fedPass
echo "Enter Debian root password: "
read debPass
stty echo
python3 etc/manticore/netListenerSetup.py "172.20.241.30" $ecomPass &
python3 etc/manticore/netListenerSetup.py "172.20.241.40" $fedPass &
python3 etc/manticore/netListenerSetup.py "172.20.240.20" $debPass &
sleep 60