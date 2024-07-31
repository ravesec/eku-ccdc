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
            password = input("Enter sysadmin password: ")
            os.system("stty echo")
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(address, username="sysadmin", password=password)

            scp_command = f'scp /etc/manticore/listenerSetup sysadmin@{address}:/tmp/manticoreSetup'
            subprocess.run(scp_command, shell=True, check=True)
            print(f"Listener script copied over to {address}")
            
            command = "bash /tmp/manticoreSetup"
            stdin, stdout, stderr = ssh_client.exec_command(f"echo {password} | sudo -S {command}")
            error = stderr.read().decode('utf-8')
            if(len(error) > 0):
                print(f"An error occured: {error}")
            time.sleep(1)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
main()
    