# Use the Ubuntu base image
FROM ubuntu:latest

# Avoid apt prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install packages
RUN apt update && \
    apt upgrade -y && \
    apt install git python3 nano pip software-properties-common file sudo curl net-tools iputils-* iproute2 -y && \
    apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN mkdir /root/shared
RUN add-apt-repository --yes --update ppa:ansible/ansible && \
    apt install --yes ansible && \
    ansible-galaxy collection install paloaltonetworks.panos && \
    pip install pan-python pan-os-python

# Clone repo
RUN git clone https://github.com/profg-ul/eku-ccdc.git

WORKDIR /root/eku-ccdc/scripts/ansible-playbooks
RUN git pull
