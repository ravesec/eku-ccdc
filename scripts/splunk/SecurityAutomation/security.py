import paramiko
import os
import sys
import subprocess
import time

def main():
    if(len(sys.argv) != 2):
        print("""
User controller for the secService module used in Splunk automation.
---------------------------------------------------------------------

-h     |     Help menu

-r     |     Refreshes the service, used in the case of password and/or other config change.

-s     |     Displays operational status of all involved scripts and/or files.

""")
        return
    if(sys.argv[1].lower() in ("-r")):
        print("Restarting service.")
        killProcess(secService.py)
        os.system("systemctl start security.service")
        if(checkStatus(secService.py)):
            print("Successfully restarted service.")
        else:
            print("Error in starting service.")
    elif(sys.argv[1].lower() in ("-s")):
        print("""
Module status:
-----------------
""")
        if(checkStatus("secService.py")):
                os.system("echo -e "+"Service status: "+"\033[32m[ACTIVE]\033[0m")
            else:
                os.system("echo -e "+"Service status: "+"\033[31m[INACTIVE]\033[0m")
        
def killProcess(name):
    ps_output = subprocess.check_output(["ps", "-ef"])
    ps_lines = ps_output.decode("utf-8").split("\n")
    for line in ps_lines:
        if name in line:
            pid = int(line.split(None, 1)[1].split()[0])
            os.kill(pid, 9)
def checkStatus(fileName):
    ps_output = subprocess.check_output(["ps", "-ef"])
    ps_lines = ps_output.decode("utf-8").split("\n")
    for line in ps_lines:
        if fileName in line:
            return True
    else:
        return False