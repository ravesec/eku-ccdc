#!/bin/bash
sudo apt update
sudo apt install --yes apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt-cache policy docker-ce
sudo apt install --yes docker-ce
sudo systemctl enable docker
sudo docker build --no-cache -t ekuccdc:latest docker/
sudo docker run --rm --name ekuccdc --volume /home/sysadmin:/root/shared --hostname ekuccdc-docker ekuccdc:latest /bin/bash -c "cp /root/.ssh/id_rsa.pub /root/shared/id_rsa.pub && sleep 45 && ansible-playbook -i inventory configure.yml"

while true; do
  sudo docker inspect ekuccdc > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    success "Firewall configured successfully!"
    break
  else
    warn "Firewall configuration script running..."
    sleep 5
  fi
done

