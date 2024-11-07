import os
import paramiko
import sys
import subprocess
import time
def main():
    if(len(sys.argv) != 2):
        print("Invalid usage")
    else:
        address = sys.argv[1]
        try:
            os.system("stty -echo")
            password = input("Enter root password: ")
            os.system("stty echo")
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(address, username="root", password=password)

            scp_command = f'scp /etc/manticore/listenerSetup root@{address}:/tmp/manticoreSetup'
            subprocess.run(scp_command, shell=True, check=True)
            print(f"Listener script copied over to {address}")
            
            print("Installing listener on " + address)
            command = "bash /tmp/manticoreSetup &"
            stdin, stdout, stderr = ssh_client.exec_command(f"echo {password} | sudo -S {command}")
            time.sleep(60)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
main()
    