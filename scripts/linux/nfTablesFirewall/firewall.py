import os
import subprocess
import sys
import argparse
from datetime import datetime

def main():
    if(os.getuid() != 0):
        print("Access Denied. Must be run as root.")
    else:
        if(len(sys.argv) == 2):
            if(sys.argv[1].lower() in ('-h', '--help', 'help')):
                print("""
Firewall interface for linux machines using nftables. Written for use by EKU's CCDC team in practice and live environments.


Command line arguments:

-h , --help    |     Displays this help menu and exits.


In-Program Commands:

help           |     Displays this help menu.
""")
        else:
            x = True
            while(x):
                option = input("[Command@Core]# ")
                if(option.lower() in ('table')):
                    tableList = getTableList()
                    print("List of tables: ")
                    for table in tableList:
                        print(table)
                    option = input("Which table would you like to move to? ")
                    y = True
                    while(y):
                        for table in tableList:
                            if(table == option):
                                y = False
                        if(y):
                            print("Invalid selection.")
                    tableCommand(option)
                elif(option.lower() in ('add')):
                    print("Adding a table...")
                    name = input("Enter table name: ")
                    os.system("nft add table "+name)
                else:
                    print("""
Firewall interface for linux machines using nftables. Written for use by EKU's CCDC team in practice and live environments.


Command line arguments:

    -h , --help    |     Displays this help menu and exits.


In-Program Commands:

    help           |     Displays this help menu.

    Core Commands:
    
    table          |     Changes command focus to a specific table.
    add            |     Adds a new table to the ip family.
    
    Table Commands:
    
    chain          |     Changes command focus to a specific chain within the table.
    add            |     Adds a new chain to the selected table.
    clear          |     Clears out the current table. This will remove all rules associated with the current table.
    delete         |     Removes a stated chain from the current table.
    
    Chain Commands:


""")
def tableCommand(table):
    x = True
    while(x):
        option = input(f"[Command@{table}]# ")
        if(option.lower() in ('exit')):
            return
        elif(option.lower() in ('add')):
            print(f"Adding chain to {table}")
            name = input("Enter name for new chain: ")
            hook = input("Enter chain hook(ingress, preroute, input, forward, output, postroute): ")
            type = input("Enter chain type(nat, route, filter): ")
            priority = input("Enter chain priority: ")
            os.system("nft add chain "+table+" "+name+" \{ type "+type+" hook "+hook+" priority "+priority+" \; policy drop\; \}")
            print(f"Chain {name} added to {table}")
        elif(option.lower() in ('chain')):
            chain = input("Enter chain to move to: ")
            chainCommand(table, chain)
        elif(option.lower() in ('clear')):
            print(f"Please note, this will remove all rules in the table {table}. Doing so could result in a loss of firewall function if this table contains firewall rules.")
            option = input(f"Are you sure you would like to clear {table}? ")
            if(option.lower() in ('y', 'yes')):
                os.system("nft flush table "+table)
                print(f"{table} cleared.")
        elif(option.lower() in ('delete')):
            chain = input("What chain would you like to remove? ")
            os.system("nft flush chain "+table+" "+chain)
            os.system("nft delete chain "+table+" "+chain)
            print(f"{chain} deleted.")
def chainCommand(table, chain):
    x = True
    while(x):
        option = input(f"[Command@{table}:{chain}]# ")
        if(option.lower() in ('exit')):
            return
        
def getTableList():
    tableList = []
    tableOutput = subprocess.check_output(["nft", "list tables"])
    tableListRaw = tableOutput.decode("utf-8").split("\n")
    for line in tableListRaw:
        lineList = line.split(" ")
        tableList.append(lineList[-1])
    return tableList
main()