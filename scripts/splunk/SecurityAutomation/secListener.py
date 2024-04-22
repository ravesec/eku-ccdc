import os
import sys
import subprocess

def main():
    if(len(sys.argv) != 3):
        print("Invalid usage.")
    else:
        if(exemption(sys.argv[1]) == sys.argv[2]):
            os.system("wall \"Splunk has detected a compromise of this machine and the incident has been reported. All other machines on the network have isolated this machine.\"")
        else:
            response(sys.argv[2])
def exemption(machine):
    if(machine == "centos"):
        return "1"
    elif(machine == "fedora"):
        return "2"
    elif(machine == "debian"):
        return "3"
    elif(machine == "ubuntu"):
        return "4"
def response(value):
    if(value == "999"):
        os.system("wall \"Splunk has detected a possible compromise of itself. Blocking Splunk. Automated alerts will no longer come in until manually opened again.\"")
        os.system("echo \"sshd: 172.20.241.20 \n\" >> /etc/hosts.deny")
    elif(value == "1"):
        os.system("wall \"Splunk has detected a possible compromise of the CentOS machine. Isolating.\"")
        os.system("echo \"sshd: 172.20.241.30 \n\" >> /etc/hosts.deny")
    elif(value == "2"):
        os.system("wall \"Splunk has detected a possible compromise of the Fedora machine. Isolating.\"")
        os.system("echo \"sshd: 172.20.241.40 \n\" >> /etc/hosts.deny")
    elif(value == "3"):
        os.system("wall \"Splunk has detected a possible compromise of the Debian machine. Isolating.\"")
        os.system("echo \"sshd: 172.20.240.20 \n\" >> /etc/hosts.deny")
    elif(value == "4"):
        os.system("wall \"Splunk has detected a possible compromise of the Ubuntu machine. Isolating.\"")
        os.system("echo \"sshd: 172.20.242.10 \n\" >> /etc/hosts.deny")
def killProcess(name):
    ps_output = subprocess.check_output(["ps", "-ef"])
    ps_lines = ps_output.decode("utf-8").split("\n")
    for line in ps_lines:
        if name in line:
            pid = int(line.split(None, 1)[1].split()[0])
            os.kill(pid, 9)
main()