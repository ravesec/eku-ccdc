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
                printHelp()
        else:
            x = True
            while(x):
                option = input("[Command@Core]# ")
                if(option.lower() in ('table')):
                    tableList = getTableList()
                    print("List of tables: ")
                    for table in tableList:
                        print(table)
                    y = True
                    while(y):
                        option = input("Which table would you like to move to? ")
                        for table in tableList:
                            if(table == option):
                                y = False
                        if(y):
                            print("Invalid selection.")
                    if(tableCommand(option) == "quit"):
                        return
                elif(option.lower() in ('add')):
                    print("Adding a table...")
                    name = input("Enter table name: ")
                    os.system("nft add table "+name)
                else:
                    printHelp()
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
            if(chainCommand(table, chain) == "quit"):
                return "quit"
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
        elif(option.lower() in ('quit')):
            return "quit"
        elif(option.lower() in ('view')):
            getChainList(table)
        else:
            printHelp()
def chainCommand(table, chain):
    x = True
    while(x):
        option = input(f"[Command@{table}:{chain}]# ")
        if(option.lower() in ('exit')):
            return
        elif(option.lower() in ('quit')):
            return "quit"
        elif(option.lower() in ('add')):
            print(f"Adding exclusion to chain {chain}.")
            y = True
            while(y):
                option = input("Exclude IP or Port? ")
                if(option.lower() in ('ip', 'port')):
                    y = False
            y = True
            while(y):
                stance = input(f"Filter by source or destination {option}? ")
                if(stance.lower() in ('source', 'destination')):
                    y = False
            if(option.lower() in ('ip')):
                ips = input("Enter list of IPs to exclude seperated by spaces: ")
                list = ips.split(" ")
                exclude = list[0]
                del list[0]
                for ip in list:
                    exclude = exclude + ", "+ip
                if(stance.lower() in ('source')):
                    os.system("nft add rule "+table+" "+chain+" ip saddr { "+exclude+" } accept")
                elif(stance.lower() in ('destination')):
                    os.system("nft add rule "+table+" "+chain+" ip daddr { "+exclude+" } accept")
            elif(option.lower() in ('port')):
                y = True
                while(y):
                    type = input("tcp or udp? ")
                    if(type.lower() in ('tcp', 'udp')):
                        y = False
                ports = input("Enter list of ports/services(http/https/ssh) to exclude seperated by spaces: ")
                list = ports.split(" ")
                exclude = list[0]
                del list[0]
                for port in list:
                    exclude = exclude + ", "+port
                if(stance.lower() in ('source')):
                    os.system("nft add rule "+table+" "+chain+" "+type+" sport { "+exclude+" } accept")
                elif(stance.lower() in ('destination')):
                    os.system("nft add rule "+table+" "+chain+" "+type+" dport { "+exclude+" } accept")
            print(f"New rule added to {chain}.")
        else:
            printHelp()
def getTableList():
    tableList = []
    tableOutput = subprocess.check_output(["nft", "list tables"])
    tableListRaw = tableOutput.decode("utf-8").split("\n")
    for line in tableListRaw:
        lineList = line.split(" ")
        tableList.append(lineList[-1])
    return tableList
def getChainList(table):
    chainList = []
    command = f"list table {table}"
    chainOuput = subprocess.check_output(["nft", command])
    chainListRaw = chainOutput.decode('utf-8').split("chain")
    del chainListRaw[0]
    for line in chainListRaw:
        lineList = line.split(" ")
        chainList.append(lineList[1])
    return chainList
def printHelp():
    print("""
Firewall interface for linux machines using nftables. Written for use by EKU's CCDC team in practice and live environments.


Command line arguments:

    -h , --help    |     Displays this help menu and exits.


In-Program Commands:

    help           |     Displays this help menu.
    exit           |     Exits out of current command focus and returns to the previous layer. (ex. using "exit" while in a specific chain moves the focus to the table that contains the chain)
    quit           |     Quits out of program.

    Core Commands:
    
    table          |     Changes command focus to a specific table.
    add            |     Adds a new table to the ip family.
    
    Table Commands:
    
    chain          |     Changes command focus to a specific chain within the table.
    add            |     Adds a new chain to the selected table.
    clear          |     Clears out the current table. This will remove all rules associated with the current table.
    delete         |     Removes a stated chain from the current table.
    
    Chain Commands:

    add            |     Adds a new rule to the selected chain.
    
    
""")
main()