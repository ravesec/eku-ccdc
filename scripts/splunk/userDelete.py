#!/usr/bin/env python3
import os
import file
def main():
    f = open(/etc/passwd, "r")
    passwdFile = f.read()
    passwdLines = passwdFile.split("\n")
    for line in passwdLine:
        userInfo = line.split(":")
        username = userInfo[0]
        uid = userInfo[2]
        gid = userInfo[3]
        if(uid > 1001 or gid > 1001 and username != "nobody"):
            os.system(f"pkill -u {username}")
            os.system(f"userdel -f {username}")
main()