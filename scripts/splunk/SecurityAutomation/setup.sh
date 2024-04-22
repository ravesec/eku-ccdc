#!/bin/bash
machine=$1
if [ $machine=="centos" ]
then
yum install -y python3
adduser splunkListener
echo splunkListener:changeme | chpasswd
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
rm $0