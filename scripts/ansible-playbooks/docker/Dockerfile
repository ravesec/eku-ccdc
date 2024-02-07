# Use the Ubuntu base image
FROM ubuntu:latest

# Avoid apt prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install packages
RUN apt update && \
    apt upgrade -y && \
    apt install git ssh python3 pip software-properties-common file vim sudo curl net-tools iputils-* iproute2 -y && \
    apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN add-apt-repository --yes --update ppa:ansible/ansible && \
    apt install --yes ansible && \
    ssh-keygen -t rsa -f /root/id_rsa -q -N "" && \
    ansible-galaxy collection install paloaltonetworks.panos && \
    pip install pan-python pan-os-python

# Clone repo
RUN git clone https://github.com/profg-ul/eku-ccdc.git
RUN cp /root/id_rsa.pub /root/shared/id_rsa.pub

WORKDIR /root/eku-ccdc/scripts/ansible-playbooks
RUN git pull
