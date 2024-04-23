import os
import sys
import subprocess
import paramiko

ips = ["172.20.240.20", "172.20.241.30", "172.20.241.40", "172.20.242.10"] #TODO: Change these for your network, these are default for ccdc environemnts as of 2023-2024
centosPass = "changeme" #TODO: Change these passwords as any changes need to be made"
fedoraPass = "changeme"
debianPass = "changeme"
ubuntuPass = "changeme"
def main():
    if(len(sys.argv) == 1):
        print("Invalid usage.")
    else:
        alert = sys.argv[1]
        for ip in ips:
            password = switch(ip) + "Pass"
            execute(ip, "/etc/secListener.py", switch(ip), "splunkListener", password, alert)
def execute(ip, path, name, user, password, alert):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=user, password=password)
                    
        stdin, stdout, stderr = ssh_client.exec_command(f"sudo python3 {path} {name} {alert}")
        print(f"Executing alert script on {name}...")
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
main()