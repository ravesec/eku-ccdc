#!/usr/bin/env python3
import os
import subprocess
import time
lowerLetter = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
upperLetter = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

suspiciousServices = ["system(x)"] 
#Possible entry formats:
#"[service name]" - Searches directly for the service name entered
#"[serviceName(x)]" - Searches for the listed name, along with any variation of the service name where 'x' is a lowercase letter
#"[serviceName(X)]" - Searches for the listed name, along with any variation of the service name where 'x' is an uppercase letter
#"[serviceName(n)]" - Searches for the listed name, along with any variation of the service name where 'n' is a number 0-9
#Note: variable entries can occur anywhere in the name
def main():
    while True:
        entryList = getServiceList()
        for service in suspiciousServices:
            entries = processEntry(service)
            for entry in entries:
                if(entry in entryList):
                    #ENTER REPORTING CODE HERE
                    
        if(len(getFileCont("/etc/crontab")) != 0):
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
main()