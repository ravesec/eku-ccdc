#!/usr/bin/env python3
import os
import subprocess
import time
import socket
lowerLetter = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
upperLetter = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

whiteListUsers = ["root", "sysadmin", "sshd", "sync", "_apt", "nobody"]
revShellFlags = ["/bin/nc", "import pty", "pty.spawn"]
suspiciousServices = ["system(x)", "discord.exe", "snapchat.exe", "minecraft.exe"]
serviceOverride = ["systemd"]
suspiciousFileNames = ["shell.php", "template.php"]
#Possible entry formats:
#"[service name]" - Searches directly for the service name entered
#"[serviceName(x)]" - Searches for the listed name, along with any variation of the service name where 'x' is a lowercase letter
#"[serviceName(X)]" - Searches for the listed name, along with any variation of the service name where 'x' is an uppercase letter
#"[serviceName(n)]" - Searches for the listed name, along with any variation of the service name where 'n' is a number 0-9
#Note: variable entries can occur anywhere in the name, but only in one place
def main():
    if(not os.path.exists("/var/log/gemini.log")):
        os.system("touch /var/log/gemini.log")
    while True:
        entryList = getServiceList()
        processList = getProcessList()
        loginList = getLoginList()
        prestashopDirectory = findFiles("/var/www/")
        
        for service in suspiciousServices:
            entries = processEntry(service)
            for entry in entries:
                if(entry in entryList and entry not in serviceOverride):
                    os.system("systemctl stop " + entry)
                    os.system("systemctl disable " + entry)
                    os.system("mkdir /.quarantine/Q-S-" + entry)
                    os.system("mv /etc/systemd/system/" + entry + " /.quarantine/Q-S-" + entry)
                    os.system("mv /usr/lib/systemd/system/" + entry + " /.quarantine/Q-S-" + entry)
                    os.system("systemctl daemon-reload")
                    os.system("systemctl reset-failed")
                    log = '[' + time.ctime() + '] - A suspicious service was found and quarintined: ' + entry
                    os.system('echo "' + log + '" >> /var/log/gemini.log')
        
        #POSS QUARANTINE CHANGE
        crontabFileCont = getFileCont("/etc/crontab")
        if(len(crontabFileCont) != 0 and crontabFileCont != "\n"):
            os.system('echo "" > /etc/crontab')
            log = '[' + time.ctime() + '] - Changes were detected in /etc/crontab and removed: ' + crontabFileCont[:len(crontabFileCont)-1]
            os.system('echo "' + log + '" >> /var/log/gemini.log')
            
        #POSS QUARANTINE CHANGE
        passwdContent = getFileCont("/etc/passwd")
        passwdLine = passwdContent.split("\n")
        del(passwdLine[len(passwdLine)-1])
        for line in passwdLine:
            userInfo = line.split(":")
            username = userInfo[0]
            uid = int(userInfo[2])
            gid = int(userInfo[3])
            if((uid > 999 or gid > 999) and username not in whiteListUsers):
                os.system("userdel -f " + username)
                log = '[' + time.ctime() + '] - An unknown user with UID/GID above 999 was found and removed: ' + username
                os.system('echo "' + log + '" >> /var/log/gemini.log')

        for flag in revShellFlags:
            for process in processList:
                if(flag in process):
                    #ENTER REPORTING CODE HERE
                    
        for line in loginList:
            remoteLogin = False
            loginSplit = line.split(" ")
            x = 0
            while(x < len(loginSplit)):
                if(loginSplit[x] == ''):
                    del(loginSplit[x])
                else:
                    x = x + 1
            user = loginSplit[0]
            interface = loginSplit[1]
            dateTime = loginSplit[2] + " " + loginSplit[3]
            if(len(loginSplit) == 5):
                remoteLogin = True
                remoteAddress = loginSplit[4]
            if(remoteLogin):
                #ENTER REPORTING CODE HERE
            
        for targetFile in suspiciousFileNames:
            for file in prestashopDirectory:
                if(targetFile in file):
                    os.system("mv " + file + " /.quarantine/Q-F-" + targetFile)
                    log = '[' + time.ctime() + '] - A suspicious file was found in /var/www/ and was quarantined: ' + file
                    os.system('echo "' + log + '" >> /var/log/gemini.log')
                
        time.sleep(60)
def getFileCont(file):
    command = "cat " + file
    try:
        fileCont = subprocess.check_output(command, shell=True)
        fileDecode = fileCont.decode("utf-8")
        return fileDecode
    except subprocess.CalledProcessError as e:
        return ""
def processEntry(service):
    returnList = [service]
    num = 0
    x = False
    y = False
    for character in service:
        if(not y):
            if(x):
                if(character == "x"):
                    serviceSplitFront = service[:num-1]
                    serviceSplitEnd = service[num+2:]
                    for letter in lowerLetter:
                        returnList.append(serviceSplitFront + letter + serviceSplitEnd)
                if(character == "X"):
                    serviceSplitFront = service[:num-1]
                    serviceSplitEnd = service[num+2:]
                    for letter in upperLetter:
                        returnList.append(serviceSplitFront + letter + serviceSplitEnd)
                if(character == "n"):
                    serviceSplitFront = service[:num-1]
                    serviceSplitEnd = service[num+2:]
                    for number in numbers:
                        returnList.append(serviceSplitFront + number + serviceSplitEnd)
                y = True
            if(character == "("):
                x = True
        else:   
            y = False
        num = num + 1
    return returnList
def getServiceList():
    try:
        output = subprocess.run(["systemctl", "list-unit-files"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return output.stdout
    except subprocess.CalledProcessError as e:
        print("An error occured: " + e.stderr)
        return ""
def getProcessList():
    try:
        processOutput = subprocess.check_output(["ps", "-ef"])
        processLines = processOutput.decode("utf-8").split("\n")
        return processLines
    except subprocess.CalledProcessError as e:
        return []
def getLoginList():
    try:
        loginOutput = subprocess.check_output(["who"])
        loginDecode = loginOutput.decode("utf-8").split("\n")
        del(loginDecode[len(loginDecode)-1])
        return loginDecode
    except subprocess.CalledProcessError as e:
        return []
def findFiles(origin):
    fileList = []
    for root, dirs, files in os.walk(origin):
        for file in files:
            path = os.path.join(root, file)
            fileList.append(path)
    return fileList
def processService(serviceFileName): #Returns in the following format: [description:String, type:String, [execStart_command:String, is_file_used:Bool]]
    executedCommand = []
    serviceType = ""
    desc = ""
    serviceCont = getFileCont(serviceFileName)
    contSplit = serviceCont.split('\n')
    for line in contSplit:
        line = line.lower()
        if(len(line) == 0):
            pass
        elif("execstart" in line):
            command = line[10:]
            if('/bin/bash -c ' in line):
                remainingCommand = command[13:]
            elif('/bin/python3 -c ' in line):
                remainingCommand = command[16:]
            else:
                remainingCommand = ""
                
            if('/' in remainingCommand):
                isFile = True
            else:
                isFile = False
            
            executedCommand = [command, isFile]
        elif("description" in line):
            desc = line[12:]
        elif("type" in line):
            serviceType = line[5:]
    return [desc, serviceType, executedCommand]
main()