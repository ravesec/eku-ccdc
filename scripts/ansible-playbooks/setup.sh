#!/bin/bash
script_name="setup.sh"
source ../../config_files/ekurc
sudo apt update
sudo apt install --yes python3 pip apt-transport-https ca-certificates curl software-properties-common
pip install pwn pan-python pan-os-python
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install --yes docker-ce
sudo systemctl enable docker
sudo docker build -t ekuccdc:latest docker/
sudo docker run --rm -it ekuccdc:latest /bin/bash -c "nano configure.yml && ansible-playbook -i inventory configure.yml"
success "Script complete!"
