#!/usr/bin/env python3
import os
import socket
import sys
import random
port = int(sys.argv[1])
def main():
    sock = socket.create_server(("0.0.0.0", port))
    sock.listen()
    while(True):
        array = sock.accept()
        conn = array[0]
        address = array[1]
        length = 1
        if(address[0] != "172.20.241.20"):
            length = 0
        while(length > 0):
            message = conn.recv(4096)
            if(len(message) == 0):
                length = 0
            else:
                dec = message.decode('utf-8')
                trueMes = decrypt(dec)
                messageArray = trueMes.split('-')
                if(messageArray[1] == "C17"):
                    address = messageArray[2]
                    os.system('firewall -ba ' + address)
                if(messageArray[1] == "H10"):
                    address = messageArray[2]
                    if(address == "172.20.241.20"):
                        heartSock = socket.create_connection(("172.20.241.20", 1894))
                        message = encrypt("H11", "0.0.0.0")
                        heartSock.send(message.encode('utf-8'))
                        heartSock.shutdown(socket.SHUT_WR)
                        heartSock.close()
                if(messageArray[1] == "S99"):
                    address = messageArray[2]
                    hostName = getHostName(address)
                    os.system("bash /etc/eku-ccdc/scripts/linux/Manticore/remoteSetup.sh "+ hostName + " &")
                if(messageArray[1] == "G99"):
                    os.system("bash /etc/eku-ccdc/scripts/linux/Gemini/install.sh")
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
def getHostName(host_addr):
    return {
            "172.20.240.20": "debian",
            "172.20.242.10": "ubuntu",
            "172.20.241.30": "centos",
            "172.20.241.40": "ecomm"
        }.get(host_addr, "")
main()