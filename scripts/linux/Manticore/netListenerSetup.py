import os
import paramiko
import sys
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
            command = """cat <<EOFA > /etc/setup
yum install -y nftables 
yum install -y python3
if ! [ -d /etc/eku-ccdc ]
then
git clone https://github.com/ravesec/eku-ccdc /etc/eku-ccdc
fi
mv /etc/eku-ccdc/scripts/linux/Manticore/listener.py /bin/manticoreListener
chmod +x /bin/manticoreListener
manticoreListener "1893"
EOFA
"""
            stdin, stdout, stderr = ssh_client.exec_command(f"echo {password} | sudo -S {command}")
            error = stderr.read().decode('utf-8')
            if(len(error) > 0):
                print(f"An error occured: {error}")
            time.sleep(1)
            
            command = "bash /etc/setup"
            stdin, stdout, stderr = ssh_client.exec_command(f"echo {password} | sudo -S {command}")
            error = stderr.read().decode('utf-8')
            if(len(error) > 0):
                print(f"An error occured: {error}")
            time.sleep(1)
        except Exception as e:
            print(f"An error occurred: {str(e)}")
main()
    