import os
import sys

#TODO: Add all services/ports and all IPs that you want allowed by default
requiredServicesTCP = ["53", "http", "https"] #ports/services allowed to freely talk both ways
inOnlyServicesTCP = [] #ports/services only allowed to recieve traffic, not send
outOnlyServicesTCP = [] #ports/services only allowed to send traffic, not recieve
requiredServicesUDP = [] #ports/services allowed to freely talk both ways
inOnlyServicesUDP = [] #ports/services only allowed to recieve traffic, not send
outOnlyServicesUDP = [] #ports/services only allowed to send traffic, not recieve
requiredIPs = ["127.0.0.1", "8.8.8.8", "8.8.4.4"] #IPs allowed to send traffic to and recieve trafic from this machine
inOnlyIPs = [] #IPs only allowed to send traffic to this machine.
outOnlyIPs = [] #IPs only allowed to recieve traffic from this machine.

def main():
    if(len(sys.argv) == 2):
        if(sys.argv(1) == "splunk"):
            splSetup()
            return
    os.system("nft add table firewall")
    os.system("nft add table blacklist")
    os.system("nft add chain firewall input \{ type filter hook input priority 0 \; policy drop\; \}")
    os.system("nft add chain firewall output \{ type filter hook output priority 0 \; policy drop\; \}")
    os.system("nft add chain blacklist blockIn \{ type filter hook input priority -99 \; policy continue\; \}")
    os.system("nft add chain blacklist blockOut \{ type filter hook output priority -99 \; policy continue\; \}")
    for service in requiredServicesTCP:
        os.system("nft add rule firewall input tcp sport { "+service+" } accept")
        os.system("nft add rule firewall input tcp dport { "+service+" } accept")
        os.system("nft add rule firewall output tcp dport { "+service+" } accept")
        os.system("nft add rule firewall output tcp sport { "+service+" } accept")
    for service in inOnlyServicesTCP:
        os.system("nft add rule firewall input tcp dport { "+service+" } accept")
    for service in outOnlyServicesTCP:
        os.system("nft add rule firewall output tcp sport { "+service+" } accept")
    for service in requiredServicesUDP:
        os.system("nft add rule firewall input udp sport { "+service+" } accept")
        os.system("nft add rule firewall input udp dport { "+service+" } accept")
        os.system("nft add rule firewall output udp dport { "+service+" } accept")
        os.system("nft add rule firewall output udp sport { "+service+" } accept")
    for service in inOnlyServicesUDP:
        os.system("nft add rule firewall input udp dport { "+service+" } accept")
    for service in outOnlyServicesUDP:
        os.system("nft add rule firewall output udp sport { "+service+" } accept")
    for ip in requiredIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    for ip in inOnlyIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
    for ip in outOnlyIPs:
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    
    os.remove(sys.argv[0])
main()
def splSetup():
    requiredServicesTCP = ["53", "http", "https", "8080", "1893"] #ports/services allowed to freely talk both ways
    inOnlyServicesTCP = [] #ports/services only allowed to recieve traffic, not send
    outOnlyServicesTCP = [] #ports/services only allowed to send traffic, not recieve
    requiredServicesUDP = [] #ports/services allowed to freely talk both ways
    inOnlyServicesUDP = [] #ports/services only allowed to recieve traffic, not send
    outOnlyServicesUDP = [] #ports/services only allowed to send traffic, not recieve
    requiredIPs = ["127.0.0.1", "8.8.8.8", "8.8.4.4"] #IPs allowed to send traffic to and recieve trafic from this machine
    inOnlyIPs = [] #IPs only allowed to send traffic to this machine.
    outOnlyIPs = [] #IPs only allowed to recieve traffic from this machine.
    os.system("nft add table firewall")
    os.system("nft add table blacklist")
    os.system("nft add chain firewall input \{ type filter hook input priority 0 \; policy drop\; \}")
    os.system("nft add chain firewall output \{ type filter hook output priority 0 \; policy drop\; \}")
    os.system("nft add chain blacklist blockIn \{ type filter hook input priority -99 \; policy continue\; \}")
    os.system("nft add chain blacklist blockOut \{ type filter hook output priority -99 \; policy continue\; \}")
    for service in requiredServicesTCP:
        os.system("nft add rule firewall input tcp dport { "+service+" } accept")
        os.system("nft add rule firewall output tcp sport { "+service+" } accept")
    for service in inOnlyServicesTCP:
        os.system("nft add rule firewall input tcp dport { "+service+" } accept")
    for service in outOnlyServicesTCP:
        os.system("nft add rule firewall output tcp sport { "+service+" } accept")
    for service in requiredServicesUDP:
        os.system("nft add rule firewall input udp dport { "+service+" } accept")
        os.system("nft add rule firewall output udp sport { "+service+" } accept")
    for service in inOnlyServicesUDP:
        os.system("nft add rule firewall input udp dport { "+service+" } accept")
    for service in outOnlyServicesUDP:
        os.system("nft add rule firewall output udp sport { "+service+" } accept")
    for ip in requiredIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    for ip in inOnlyIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
    for ip in outOnlyIPs:
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    os.remove(sys.argv[0])