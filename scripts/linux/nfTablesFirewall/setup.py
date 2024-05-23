import os
import sys

requiredServicesTCP = ["53", "ssh", "http", "https"]  #TODO: Add all services/ports and all IPs that you want allowed by default
inOnlyServicesTCP = []
outOnlyServicesTCP = []
requiredServicesUDP = []
inOnlyServicesUDP = []
outOnlyServicesUDP = []
requiredIPs = ["127.0.0.1", "8.8.8.8", "8.8.4.4"]
inOnlyIPs = []
outOnlyIPs = []

def main():
    os.system("nft add table firewall")
    os.system("nft add table blacklist")
    os.system("nft add chain firewall input \{ type filter hook input priority 0 \; policy drop\; \}")
    os.system("nft add chain firewall output \{ type filter hook output priority 0 \; policy drop\; \}")
    os.system("nft add chain blacklist blockIn \{ type filter hook input priority -99 \; policy accept\; \}")
    os.system("nft add chain blacklist blockOut \{ type filter hook output priority -99 \; policy accept\; \}")
    for service in requiredServicesTCP:
        os.system("nft add rule firewall input tcp sport { "+service+" } accept")
        os.system("nft add rule firewall input tcp dport { "+service+" } accept")
        os.system("nft add rule firewall output tcp dport { "+service+" } accept")
        os.system("nft add rule firewall output tcp sport { "+service+" } accept")
    for service in inOnlyServicesTCP:
        os.system("nft add rule firewall input tcp sport { "+service+" } accept")
    for service in outOnlyServicesTCP:
        os.system("nft add rule firewall output tcp dport { "+service+" } accept")
    for service in requiredServicesUDP:
        os.system("nft add rule firewall input udp sport { "+service+" } accept")
        os.system("nft add rule firewall output udp dport { "+service+" } accept")
    for service in inOnlyServicesUDP:
        os.system("nft add rule firewall input udp sport { "+service+" } accept")
    for service in outOnlyServicesUDP:
        os.system("nft add rule firewall output udp dport { "+service+" } accept")
    for ip in requiredIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    for ip in inOnlyIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
    for ip in outOnlyIPs:
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    
    os.remove(sys.argv[0])
main()