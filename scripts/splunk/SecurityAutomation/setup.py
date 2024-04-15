import paramiko
import os
import sys
import subprocess
import time

ips = ["172.20.240.20", "172.20.241.30", "172.20.241.40", "172.20.242.10"] #TODO: Change these for your network, these are default for ccdc environemnts as of 2023-2024
def main():
    if(len(sys.argv) != 1):
        if(sys.argv[1] == "-t" or sys.argv[1] == "-T"):
            os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/setup.sh /etc/setup")
            x = True
            while(x):
                ip = input("Enter IP Address: ")
                print("")
                if(switch(ip) == "NOT FOUND"):
                    print("Unknown IP. Try again.")
                else:
                    x = False
            name = switch(ip)
            sendFile(ip, "/etc/setup", "/etc/destSetup", name)
            os.system("stty -echo")
            password = input(f"Enter password for {name}\'s root: " )
            os.system("stty echo")
            print("")
            else:
                execute(ip, "/etc/setup", name, password)
        else:
            print("""
-h    |    Help menu (This guy)

-t    |    Targeted setup. Asks for specific ip address. Designed to be used for reinstalls or in the case of a machine reset.

""")
    else:
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/setup.sh /etc/setup")
        for ip in ips:
            name = switch(ip)
            sendFile(ip, "/etc/setup", "/etc/destSetup", name)
            os.system("stty -echo")
            password = input(f"Enter password for {name}\'s root(\'b\' to bypass): " )
            os.system("stty echo")
            print("")
            if(password.lower() in ("b")):
                print(f"Bypassing {name}")
            else:
                execute(ip, "/etc/setup", name, password)
def sendFile(address, source, dest, nameAddress):
    scp_command = f'scp {source} root@{address}:{dest}'
    subprocess.run(scp_command, shell=True, check=True)
    print(f"Script copied to {nameAddress}")
def execute(ip, path, name, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(ip, username="root", password=password)
                
    stdin, stdout, stderr = ssh_client.exec_command(f"bash {path}")
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
    else:
        return "NOT FOUND"
main()