import os
import sys
import subprocess
import paramiko
import time

ips = ["172.20.240.20", "172.20.241.30", "172.20.241.40", "172.20.242.10"] #TODO: Change these for your network, these are default for ccdc environemnts as of 2023-2024
def main():
    if(len(sys.argv) == 1):
        print("Invalid usage.")
    else:
        alert = sys.argv[1]
        for ip in ips:
            execute(ip, "/etc/secListener.py", switch(ip), "splunkListener", passSwitch(ip), alert)
def execute(ip, path, name, user, password, alert):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=user, password=password)
                    
        stdin, stdout, stderr = ssh_client.exec_command(f"echo {password} | sudo -S python3 {path} {name} {alert}")
        print(f"Executing alert script on {name}...")
        error = stderr.read().decode('utf-8')
        if(len(error) > 0):
            print(f"An error occured: {error}")
        time.sleep(5)
    except Exception as e:
        print(f"An error occurred: {str(e)}")
def switch(ip):
    if ip == "172.20.240.20":
        return "debian"
    elif ip == "172.20.241.30":
        return "centos"
    elif ip == "172.20.241.40":
        return "fedora"
    elif ip == "172.20.242.10":
        return "ubuntu"
    else:
        return "NOT FOUND"
def passSwitch(ip):
    if ip == "172.20.240.20":
        return "changeme"
    elif ip == "172.20.241.30":
        return "changeme"
    elif ip == "172.20.241.40":
        return "changeme"
    elif ip == "172.20.242.10":
        return "changeme"
    else:
        return "NOT FOUND"
main()