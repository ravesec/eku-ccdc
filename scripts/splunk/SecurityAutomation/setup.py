import paramiko
import os
import sys
import subprocess
import time

ips = ["172.20.240.20", "172.20.241.30", "172.20.241.40", "172.20.242.10"] #TODO: Change these for your network, these are default for ccdc environemnts as of 2023-2024
def main():
    os.system("curl -o /etc/setup https://github.com/ravesec/eku-ccdc/scripts/splunk/SecurityAutomation/setup.sh")
    for ip in ips:
        name = switch(ip)
        sendFile(ip, "/etc/setup", "/etc/setup", name)
        os.system("stty -echo")
        password = input(f"Enter password for {name}\'s root(\'b\' to bypass: " )
        os.system("stty echo")
        if(input.lower() in ("b")):
            print(f"Bypassing {name}")
        else:
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(ip, username="root", password=password)
            execute("/etc/setup", ssh_client, name)
def sendFile(address, source, dest, nameAddress):
    scp_command = f'scp {source} root@{address}:{dest}'
    subprocess.run(scp_command, shell=True, check=True)
    print(f"Script copied to {nameAddress}")
def execute(path, ssh_client, name):
    stdin, stdout, stderr = ssh_client.exec_command(f"sudo python3 {path}")
    print(f"Executing setup script on {name}...")
    time.sleep(5)
def switch(ip):
    if ip == "172.20.240.20":
        return "Debian"
    elif ip == "172.20.241.30":
        return "CentOS"
    elif ip == "172.20.241.40":
        return "Fedora"
    elif ip == "172.20.242.10":
        return "Ubuntu"
main()