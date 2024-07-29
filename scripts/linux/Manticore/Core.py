#!/usr/bin/env python3
import os
import sys
def main():
    arguments = []
    for arg in sys.argv:
        arguments.append(arg)
    del(arguments[0])
   
main()