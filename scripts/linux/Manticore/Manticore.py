#!/usr/bin/env python3
import os
import sys
import random
def main():
    arguments = []
    for arg in sys.argv:
        arguments.append(arg)
    del(arguments[0])
    message = encrypt("C17", "10.10.10.10")
    binary = message.encode('utf-8')
    decoded = decrypt(message)
    print(binary)
    print(message)
    print(decoded)
    option = input("Ddd")
   
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