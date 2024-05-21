import os
import subprocess
import sys
import argparse
from datetime import datetime

def main():
    if ("SSH_CONNECTION" in os.environ) or ("SSH_CLIENT" in os.environ) or ("SSH_TTY" in os.environ):
        print("Unable to be run remotely.")
        return
    elif(os.getuid() != 0):
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
                    y = True
                    while(y):
                        name = input("Enter table name: ")
                        if spacePresent(name):
                            print("Invalid name, spaces not permitted.")
                        else:
                            y = False
                    os.system("nft add table "+name)
                elif(option.lower() in ('delete')):
                    tableList = getTableList()
                    for table in tableList:
                        print(table)
                    y = True
                    while(y):
                        option = input("Enter table to remove: ")
                        if(isInList(option, tableList)):
                            y = False
                        else:
                            print("Invalid selection")
                    os.system("nft delete table "+option)
                    if(isInList(option, tableList)):
                        print(f"Error removing {option}")
                    else:
                        print(f"Successfully removed {option}")
                elif(option.lower() in ('panic')):
                    panic()
                elif(option.lower() in ('blacklist')):
                    blackList()
                elif(option.lower() in ('exit', 'quit')):
                    return
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
            y = True
            while(y):
                name = input("Enter name for new chain: ")
                if spacePresent(name):
                    print("Invalid name, spaces not permitted.")
                else:
                    y = False
            hook = input("Enter chain hook(ingress, preroute, input, forward, output, postroute): ")
            type = input("Enter chain type(nat, route, filter): ")
            y = True
            while(y):
                priority = input("Enter chain priority: ")
                priorityNum = int(priority)
                if(priorityNum < -99):
                    option("Adding this chain would override the blacklist(priority -99) and/or panic mode(priority -100). Are you sure?")
                    if(option.lower() in ('y', 'yes')):
                        y = False
            os.system("nft add chain "+table+" "+name+" \{ type "+type+" hook "+hook+" priority "+priority+" \; policy drop\; \}")
            print(f"Chain {name} added to {table}")
        elif(option.lower() in ('chain')):
            chainList = getChainList(table)
            print(f"List of chains in {table}:")
            for chain in chainList:
                print(chain)
            y = True
            while(y):
                option = input("Which chain would you like to move to? ")
                for chain in chainList:
                    if(chain == option):
                        y = False
                if(y):
                    print("Invalid selection.")
            if(chainCommand(table, option) == "quit"):
                return "quit"
        elif(option.lower() in ('clear')):
            print(f"Please note, this will remove all rules in the table {table}. Doing so could result in a loss of firewall function if this table contains firewall rules.")
            option = input(f"Are you sure you would like to clear {table}? ")
            if(option.lower() in ('y', 'yes')):
                os.system("nft flush table "+table)
                chainList = getChainList(table)
                for chain in chainList:
                    os.system("nft delete chain "+table+" "+chain)
                print(f"{table} cleared.")
        elif(option.lower() in ('delete')):
            chain = input("What chain would you like to remove? ")
            os.system("nft flush chain "+table+" "+chain)
            os.system("nft delete chain "+table+" "+chain)
            print(f"{chain} deleted.")
        elif(option.lower() in ('quit')):
            return "quit"
        elif(option.lower() in ('view')):
            chainList = getChainList(table)
            for chain in chainList:
                print(chain)
        elif(option.lower() in ('panic')):
            panic()
        elif(option.lower() in ('blacklist')):
            blackList()
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
        elif(option.lower() in ('panic')):
            panic()
        elif(option.lower() in ('blacklist')):
            blackList()
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
    chainOutput = subprocess.check_output(["nft", command])
    chainListRaw = chainOutput.decode('utf-8').split("chain")
    del chainListRaw[0]
    for line in chainListRaw:
        lineList = line.split(" ")
        chainList.append(lineList[1])
    return chainList
def panic():
    tableList = getTableList()
    x = False
    for table in tableList:
        if(table == "PANIC"):
            x = True
    if(x):
        option = input("Panic mode is currently enabled. Would you like to disable it? ")
        if(option.lower() in ('y', 'yes')):
            os.system("nft flush table PANIC")
            os.system("nft delete table PANIC")
            print("Panic mode deactivated.")
        else:
            print("Panic mode remaining on.")
    else:
        print("Enabling panic mode...")
        os.system("nft add table PANIC")
        os.system("nft add chain PANIC panicChainIn \{ type filter hook input priority -100 \; policy drop\; \}")
        os.system("nft add chain PANIC panicChainOut \{ type filter hook output priority -100 \; policy drop\; \}")
        print("Panic mode activated. All traffic in and out blocked.")
def blackList():
    return #TODO: REMOVE WHEN HANDLE ISSUES FIXED
    blackList = getBlackList()
    print("Current list of blacklisted IPs:")
    for ip in blackList:
        print(ip[0] + " ("+ip[1]+")")
    x = True
    while(x):
        option = input("Would you like to add or remove an IP? ")
        if(option.lower() in ('add', 'remove')):
            x = False
        else:
            print("Invalid input.")
    if(option.lower() in ('add')):
        ip = input("Enter IP to add to blacklist: ")
        option = input(f"Confirmation: Adding {ip} to blacklist: ")
        if(option.lower() in ('y', 'yes')):
            os.system("nft add rule blacklist blockIn ip saddr { "+ip+" } drop")
            os.system("nft add rule blacklist blockOut ip daddr { "+ip+" } drop")
            blackList = getBlackList()
            y = False
            for heldIP in blackList:
                if(heldIP[0] == ip):
                    y = True
            if(y):
                print(f"IP {ip} successfully added to blacklist.")
            else:
                print(f"Error adding {ip} to blacklist.")
    elif(option.lower() in ('remove')):
        x = True
        while(x):
            option = input("Enter IP to remove from blacklist: ")
            for ip in blackList:
                if(ip[0] == option):
                    x = True
            if(not x):
                print(f"{option} not in blacklist.")
        for ip in blackList:
            if(ip[0] == option):
                os.system("nft delete rule blacklist blockIn handle "+ip[1])
                os.system("nft delete rule blacklist blockOut handle "+ip[1])
        blackList = getBlackList()
        y = False
        for heldIP in blackList:
            if(heldIP[0] == ip):
                y = True
        if(y):
            print(f"{ip} successfully removed from blacklist.")
        else:
            print(f"Error removing {ip} from blacklist.")
def getBlackList():
    blackList = [[]]
    blackListOutput = subprocess.check_output(["nft", "-a list table blacklist"])
    blackListRaw = blackListOutput.decode("utf-8").split("saddr ")
    del(blackListRaw[0])
    x = 0
    for line in blackListRaw:
        ipSplit = line.split(" ")
        blackList.append(ipSplit[0])
        blackList[x].append(ipSplit[4])
        x = x+1
    return blackList
def spacePresent(input):
    inputList = input.split(" ")
    if(len(inputList) != 1):
        return True
    else:
        return False
def isInList(value, list):
    for thing in list:
        if(thing == value):
            return True
    return False
def printHelp():
    print("""
Firewall interface for linux machines using nftables. Written for use by EKU's CCDC team in practice and live environments.


Command line arguments:

    -h , --help    |     Displays this help menu and exits.


In-Program Commands:

    help           |     Displays this help menu.
    exit           |     Exits out of current command focus and returns to the previous layer. (ex. using "exit" while in a specific chain moves the focus to the table that contains the chain)
    quit           |     Quits out of program.
    panic          |     Activates/Deactivates panic mode. Will only prompt confirmation when disabling panic mode.
    blacklist      |     Enters blacklist management menu. (NOT FUNCTIONAL)

    Core Commands:
    
    table          |     Changes command focus to a specific table.
    add            |     Adds a new table to the ip family.
    delete         |     Removes a table from the ip family.
    
    Table Commands:
    
    chain          |     Changes command focus to a specific chain within the table.
    add            |     Adds a new chain to the selected table.
    clear          |     Clears out the current table. This will remove all rules associated with the current table.
    delete         |     Removes a stated chain from the current table.
    view           |     Displays all chains present within the current table.
    
    Chain Commands:

    add            |     Adds a new rule to the selected chain.
    
    
""")
main()