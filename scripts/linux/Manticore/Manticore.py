#!/usr/bin/env python3
import os
import sys
import random
def main():
    arguments = []
    for arg in sys.argv:
        arguments.append(arg)
    del(arguments[0])
    print(encrypt("C17", "10.10.10.10"))
   
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
main ()