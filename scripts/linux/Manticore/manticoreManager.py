#!/usr/bin/env python3
import os
import socket
import sys
import time
import random
possHosts = ["172.20.240.20", "172.20.242.10", "172.20.241.30", "172.20.241.40"]
port = int(sys.argv[1])
sock = socket.create_server(("0.0.0.0", port))
def main():
    while(True):
        activeHosts = []
        for host in possHosts:
            message = encrypt("H10", "172.20.241.20")
            try:
                sendSock = socket.create_connection((host, 1893), timeout=5)
                sendSock.send(message.encode('utf-8'))
                array = sock.accept()
                conn = array[0]
                address = array[1]
                if(address == host):
                    recieved = conn.recv(4096)
                    dec = message.decode('utf-8')
                    trueMes = decrypt(dec)
                    messageArray = trueMes.split('-')
                    if(messageArray[1] == "H11" and messageArray[2] == "0.0.0.0"):
                        activeHosts.append(host)
            except Exception as e:
                print("An error occured with host " + host + ": " + str(e))
        fileContents = ""
        for host in activeHosts:
            fileContents = fileContents + host + "\n"
        os.system('echo "' + fileContents + '" >> /etc/manticore/hosts.list')
        time.sleep(60)
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
main()