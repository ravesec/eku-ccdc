#!/usr/bin/env python3
import os
import subprocess
import socket
import time

def main():
    



def getFileCont(file):
    command = "cat " + file
    fileCont = str(subprocess.check_output(command, shell=True))
    return fileCont[2:(len(fileCont)-1)]