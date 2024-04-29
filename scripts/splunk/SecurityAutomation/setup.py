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
            path = "/etc/destSetup " + name
            execute(ip, path, name, password)
        elif(sys.argv[1] == "-s" or sys.argv[1] == "-S"):
            option = input("Configure the splunk machine for automation? ")
            if(option.lower() in ('y')):
                names = ["centos", "debian", "ubuntu", "fedora"]
                for name in names:
                    user = name+"User"
                    os.system("useradd "+user)
                    os.system("stty -echo")
                    password = input(f"Enter password for {name}User: ")
                    os.system("stty echo")
                    os.system("echo "+user+":"+password+" | chpasswd")
            else:
                print("Exiting.")
        else:
            print("""
-h    |    Help menu (This guy)

-t    |    Targeted setup. Asks for specific ip address. Designed to be used for reinstalls or in the case of a machine reset.

-s    |    Splunk setup. Designed to be run once at the beginning of the competition. Sets up the splunk machine for automation.

""")
    else:
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/setup.sh /etc/setup")
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/secBrain.py /etc/secBrain.py")
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/centosAlert.sh /opt/splunk/bin/scripts/centosAlert.sh")
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/fedoraAlert.sh /opt/splunk/bin/scripts/fedoraAlert.sh")
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/debianAlert.sh /opt/splunk/bin/scripts/debianAlert.sh")
        os.system("mv /etc/eku-ccdc/scripts/splunk/SecurityAutomation/ubuntuAlert.sh /opt/splunk/bin/scripts/ubuntuAlert.sh")
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
                execute(ip, "/etc/destSetup", name, password)
def sendFile(address, source, dest, nameAddress):
    try:
        scp_command = f'scp {source} root@{address}:{dest}'
        subprocess.run(scp_command, shell=True, check=True)
        print(f"Script copied to {nameAddress}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
def execute(ip, path, name, password):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username="root", password=password)
                    
        stdin, stdout, stderr = ssh_client.exec_command(f"bash {path}")
        print(f"Executing setup script on {name}...")
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