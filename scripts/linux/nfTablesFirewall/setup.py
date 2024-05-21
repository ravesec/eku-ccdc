import os
import sys

requiredServices = ["http", "https", "ssh"]  #TODO: Add all services/ports and all IPs that you want allowed by default
requiredIPs = []
inOnlyServices = []
outOnlyServices = []
inOnlyIPs = []
outOnlyIPs = []

def main():
    os.system("nft add table firewall")
    os.system("nft add table blackList")
    os.system("nft add chain firewall input \{ type filter hook input priority 0 \; policy drop\; \}")
    os.system("nft add chain firewall output \{ type filter hook output priority 0 \; policy drop\; \}")
    os.system("nft add chain blackList blockIn \{ type filter hook input priority -99 \; policy accept\; \}")
    os.system("nft add chain blackList blockOut \{ type filter hook output priority -99 \; policy accept\; \}")
    for service in requiredServices:
        os.system("nft add rule firewall input sport { "+service+" } accept")
        os.system("nft add rule firewall output dport { "+service+" } accept")
    for service in inOnlyServices:
        os.system("nft add rule firewall input sport { "+service+" } accept")
    for service in outOnlyServices:
        os.system("nft add rule firewall output dport { "+service+" } accept")
    for ip in requiredIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    for ip in inOnlyIPs:
        os.system("nft add rule firewall input ip saddr { "+ip+" } accept")
    for ip in outOnlyIPs:
        os.system("nft add rule firewall output ip daddr { "+ip+" } accept")
    
    os.remove(argv[0])
main()