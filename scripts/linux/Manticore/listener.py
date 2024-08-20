#!/usr/bin/env python3
import os
import socket
import sys
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
            dec = message.decode('utf-8')
            trueMes = decrypt(dec)
            messageArray = trueMes.split('-')
            if(messageArray[1] == "C17"):
                address = messageArray[2]
                firewall "-ba" f"{address}"
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