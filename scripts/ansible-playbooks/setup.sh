#!/bin/bash
sudo apt update
sudo apt install --yes apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install --yes docker-ce
sudo systemctl enable docker
sudo systemctl status docker
sudo docker build --no-cache -t ekuccdc:latest docker/
sudo docker run --rm --it --name ekuccdc --volume /home/sysadmin:/root/shared --hostname ekuccdc-docker ekuccdc:latest
