#!/usr/bin/env python3
import os
import subprocess
import time
import socket
lowerLetter = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
upperLetter = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

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
    while True:
        entryList = getServiceList()
        processList = getProcessList()
        loginList = getLoginList()
        prestashopDirectory = findFiles("/var/www/")
        
        for service in suspiciousServices:
            entries = processEntry(service)
            for entry in entries:
                if(entry in entryList and entry not in serviceOverride):
                    #ENTER REPORTING CODE HERE
        
        crontabFileCont = getFileCont("/etc/crontab")
        if(len(crontabFileCont) != 0):
            os.system('echo "" >> /etc/crontab')
            #ENTER REPORTING CODE HERE
            
        passwdContent = getFileCont("/etc/passwd")
        passwdLine = passwdContent.split("\n")
        for line in passwdLine:
            userInfo = line.split(":")
            username = userInfo[0]
            uid = int(userInfo[2])
            gid = int(userInfo[3])
            if(uid > 1001 or gid > 1001 and username != "nobody"):
                #ENTER REPORTING CODE HERE

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
                    #ENTER REPORTING CODE HERE
                
        time.sleep(60)
def getFileCont(file):
    command = "cat " + file
    fileCont = str(subprocess.check_output(command, shell=True))
    return fileCont[2:(len(fileCont)-1)]
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
    processOutput = subprocess.check_output(["ps", "-ef"])
    processLines = processOutput.decode("utf-8").split("\n")
    return processLines
def getLoginList():
    loginOutput = subprocess.check_output(["who"])
    loginDecode = loginOutput.decode("utf-8").split("\n")
    del(loginDecode[len(loginDecode)-1])
    return loginDecode
def findFiles(origin):
    fileList = []
    for root, dirs, files in os.walk(origin):
        for file in files:
            path = os.path.join(root, file)
            fileList.append(path)
    return fileList
main()