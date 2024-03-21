import paramiko
import subprocess

def main():
    host=input("Enter address to send to: ")
    localPath=input("Enter file path to copy FROM: ")
    remotePath=input("Enter file path to copy TO: ")
    user=input("Enter destination user: ")
    password=input("Enter destination password: ")
    
    transfer(localPath, remotePath, host, user, password)

def transfer(localPath, remotePath, remoteHost, remoteUser, remotePass):
    try:
        # Use SCP to copy the local script to the remote machine
        scp_command = f'scp {local_script_path} {remote_user}@{remote_host}:{remote_script_path}'
        subprocess.run(scp_command, shell=True, check=True)
        print(f"Script copied to {remote_host}")

    except Exception as e:
        print(f"An error occurred: {str(e)}")

main()