#!/bin/bash
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc