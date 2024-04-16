import paramiko
import os
import sys
import subprocess
import time

def main():
    machine = sys.argv[1]
    while(True):
        user = machine+"User"
        password = "changeme"
        ip = "172.20.241.20"
        
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=user, password=password)
        
        stdin, stdout, stderr = ssh_client.exec_command(f"python3 /etc/bulletin")
        output = stdout.read().decode('utf-8')
        error = stderr.read().decode('utf-8')
        if(len(error) > 1):
            os.system(f"wall \"An error occured with secService: \" {error}")
        
        time.sleep(30)
def response(value):
    if(value == "999"):
        os.system("wall \"Splunk has detected a possible compromise of itself. Stopping all secService instances on all machines. Manual service restart required.\"")
main()