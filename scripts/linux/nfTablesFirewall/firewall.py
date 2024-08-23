#!/usr/bin/env python3
import os
import subprocess
import sys
import argparse
from datetime import datetime

def main():
    if(len(sys.argv) == 3):
        if(sys.argv[1] == '-ba'):
            print(addToBlackList(sys.argv[2]))
        elif(sys.argv[1] == '-br'):
            print(removeFromBlackList(sys.argv[2]))
    elif ("SSH_CONNECTION" in os.environ) or ("SSH_CLIENT" in os.environ) or ("SSH_TTY" in os.environ):
        os.system("echo -e "+"\033[0;32m[RED]\033[0m")
        #print("Unable to be run remotely.")
        return
    elif(os.getuid() != 0):
        print("Access Denied. Must be run as root.")
    else:
        if(len(sys.argv) == 2):
            if(sys.argv[1].lower() in ('-h', '--help', 'help')):
                printHelp()
            elif(sys.argv[1].lower() == "-e"):
                x = True
                while(x):
                    option = input("[Command@Core]# ")
                    if(option.lower() == ''):
                        pass
                    elif(option.lower() == 'table'):
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
                    elif(option.lower() == 'add'):
                        print("Adding a table...")
                        y = True
                        while(y):
                            name = input("Enter table name: ")
                            if spacePresent(name):
                                print("Invalid name, spaces not permitted.")
                            else:
                                y = False
                        os.system("nft add table "+name)
                    elif(option.lower() == 'delete'):
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
                    elif(option.lower() == 'panic'):
                        dam()
                    elif(option.lower() == 'blacklist'):
                        if(blackList() == "quit"):
                            return
                    elif(option.lower() == 'exit'):
                        return
                    else:
                        printHelp()
        else:
            x = True
            while(x):
                inPres = False
                outPres = False
                firewallPres = False
                firewallInteg = False
                blacklistPres = False
                blacklistInteg = False
                otherTablePres = False
                os.system("clear")
                tableList = getTableList()
                for table in tableList:
                    if(table == "firewall"):
                        firewallPres = True
                        chainList = getChainList("firewall")
                        for chain in chainList:
                            if(chain == "input"):
                                inPres = True
                            if(chain == "output"):
                                outPres = True
                        if(inPres and outPres):
                            firewallInteg = True
                    if(table == "blacklist"):
                        blacklistPres = True
                        chainList = getChainList("blacklist")
                        for chain in chainList:
                            if(chain == "input"):
                                inPres = True
                            if(chain == "output"):
                                outPres = True
                        if(inPres and outPres):
                            blacklistInteg = True
                    else:
                        otherTablePres = True
                print("EKU CCDC System Firewall Manager")
                if(firewallPres):
                    print("Firewall Status: \033[32;1m[GREEN]\033[0m")
                    if(not firewallInteg):
                        print("\033[33;1m[Caution: Firewall is active, however is missing a chain. Address this issue immediately.]\033[0m")
                else:
                    print("Firewall Status: \033[31;1m[INACTIVE]\033[0m")
                if(blacklistPres):
                    print("Blacklist Status: \033[32;1m[GREEN]\033[0m")
                    if(not blacklistInteg):
                        print("\033[33;1m[Caution: Blacklist is active, however is missing a chain. Address this issue immediately.]\033[0m")
                else:
                    print("Blacklist Status: "+"\033[31;1m[INACTIVE]\033[0m")
                if(otherTablePres):
                    print("\033[33;1m[Caution: Other tables detected present in nfTables. If this is unexpected, please investigate the issue.]\033[0m")
                if(firewallPres and firewallInteg and blacklistPres and blacklistInteg):
                    print("\n")
                    ports = []
                    ipList = []
                    inputPorts = []
                    outputPorts = []
                    inputChain = getRuleList("firewall", "input")
                    outputChain = getRuleList("firewall", "output")
                    for array in inputChain:
                        item = array[0]
                        itemArray = item.split(" ")
                        protocol = itemArray[0]
                        if(itemArray[1] == "sport" or itemArray[1] == "dport"):
                            portNum = itemArray[2]
                            if(portNum in inputPorts):
                                pass
                            else:
                                port = protocol + " " + portNum + " " + portDefault(protocol, portNum)
                                inputPorts.append(port)
                        elif(itemArray[1] == "saddr" or itemArray[1] == "daddr"):
                            if(itemArray[2] not in ipList):
                                ipList.append(itemArray[2])
                    for array in outputChain:
                        item = array[0]
                        itemArray = item.split(" ")
                        protocol = itemArray[0]
                        if(itemArray[1] == "sport" or itemArray[1] == "dport"):
                            portNum = itemArray[2]
                            if(portNum in outputPorts):
                                pass
                            else:
                                port = protocol + " " + portNum + " " + portDefault(protocol, portNum)
                                outputPorts.append(port)
                        elif(itemArray[1] == "saddr" or itemArray[1] == "daddr"):
                            if(itemArray[2] not in ipList):
                                ipList.append(itemArray[2])
                    ports = addOtherPorts(ports)
                    print("Port Rules:")
                    print("\n")
                    for port in inputPorts:
                        if(port not in ports):
                            ports.append(port)
                    for port in outputPorts:
                        if(port not in ports):
                            ports.append(port)
                    for port in ports:
                        if(port in inputPorts and port in outputPorts):
                            state = "both"
                        elif(port in inputPort):
                            state = "in"
                        elif(port in outputPort):
                            state = "out"
                        else:
                            state = "closed"
                        if(state == "both"):
                            print(port + ": \033[32;1m[OPEN]\033[0m")
                        if(state == "in"):
                            print(port + ": \033[33;1m[IN ONLY]\033[0m")
                        if(state == "out"):
                            print(port + ": \033[32;1m[OUT ONLY]\033[0m")
                        if(state == "closed"):
                            print(port + ": \033[31;1m[CLOSED]\033[0m")
                    print("\n")
                    whiteListIP = ""
                    for ip in ipList:
                        whiteListIP = whiteListIP + ", " + ip
                    print(whiteListIP)
                    print("\n")
                    option = input("Enter command: ")
                else:
                    print("Terminating to avoid crashes due to missing structure.")
                    return
def tableCommand(table):
    x = True
    while(x):
        option = input(f"[Command@{table}]# ")
        if(option.lower() == ''):
            pass
        elif(option.lower() == 'exit'):
            return
        elif(option.lower() == 'add'):
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
        elif(option.lower() == 'chain'):
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
        elif(option.lower() == 'clear'):
            print(f"Please note, this will remove all rules in the table {table}. Doing so could result in a loss of firewall function if this table contains firewall rules.")
            option = input(f"Are you sure you would like to clear {table}? ")
            if(option.lower() in ('y', 'yes')):
                os.system("nft flush table "+table)
                chainList = getChainList(table)
                for chain in chainList:
                    os.system("nft delete chain "+table+" "+chain)
                print(f"{table} cleared.")
        elif(option.lower() == 'delete'):
            option = input("What chain would you like to remove? ")
            os.system("nft flush chain "+table+" "+chain)
            os.system("nft delete chain "+table+" "+chain)
            chainList = getChainList()
            z = False
            for chain in chainList:
                if(chain == option):
                    z = True
            if(z):
                print(f"{option} deleted.")
            else:
                print(f"Error removing {option}.")
        elif(option.lower() == 'quit'):
            return "quit"
        elif(option.lower() == 'view'):
            chainList = getChainList(table)
            for chain in chainList:
                print(chain)
        elif(option.lower() == 'panic'):
            dam()
        elif(option.lower() == 'blacklist'):
            if(blackList() == "quit"):
                return "quit"
        else:
            printHelp()
def chainCommand(table, chain):
    x = True
    while(x):
        option = input(f"[Command@{table}:{chain}]# ")
        if(option.lower() == ''):
            pass
        elif(option.lower() == 'exit'):
            return
        elif(option.lower() == 'quit'):
            return "quit"
        elif(option.lower() == 'add'):
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
        elif(option.lower() == 'delete'):
            ruleList = getRuleList(table, chain)
            print(f"List of rules in {chain}:")
            for rule in ruleList:
                if(len(rule[2]) != 0):
                    print(rule[0] + " ("+rule[1]+")  ["+rule[2]+"]") 
                else:
                    print(rule[0] + " ("+rule[1]+")")
            x = True
            while(x):
                handle = input("Enter handle of rule you would like to remove: ")
                for rule in ruleList:
                    if(rule[1] == handle):
                        ruleName = rule[0]
                        x = False
                if(x):
                    print("Invalid selection.")
            verification = input(f"Confirmation: Removing rule {ruleName} from chain {chain}? ")
            if(verification.lower() == ('y', 'yes')):
                command = f"nft delete rule {table} {chain} handle {handle}"
                os.system(command)
        elif(option.lower() == 'list'):
            ruleList = getRuleList(table, chain)
            for rule in ruleList:
                if(len(rule[2]) != 0):
                    print(rule[0] + " ("+rule[1]+")  ["+rule[2]+"]") 
                else:
                    print(rule[0] + " ("+rule[1]+")")
        elif(option.lower() == 'panic'):
            dam()
        elif(option.lower() == 'blacklist'):
            if(blackList() == "quit"):
                return "quit"
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
def getRuleList(table, chain):
    ruleList = [[]]
    command = f"nft -a list table {table}"
    ruleListOutput = subprocess.check_output([command], shell=True)
    splitter = f"chain {chain}" + " {"
    ruleListRaw = ruleListOutput.decode("utf-8").split(splitter)
    del(ruleListRaw[0])
    ruleListRawStr = ruleListRaw[0]
    ruleListRaw = ruleListRawStr.split("}")
    ruleListRawStr = ruleListRaw[0]
    ruleListRaw = ruleListRawStr.split("\n")
    del(ruleListRaw[0])
    del(ruleListRaw[0])
    del(ruleListRaw[len(ruleListRaw)-1])
    for line in ruleListRaw:
        ruleInfo = line.split(" # handle ")
        ruleName = ruleInfo[0]
        ruleNameList = ruleName.split("\t")
        ruleName = ruleNameList[2]
        itemList = ruleName.split(" ")
        port = itemList[2]
        protocol = itemList[0]
        ruleHandle = ruleInfo[1]
        rule = [ruleName, ruleHandle]
        rule.append(portDefault(protocol, port))
        ruleList.append(rule)
    del(ruleList[0])
    return ruleList
def getChainInfo(table, chain):
    command = f"nft -a list table {table}"
    ruleListOutput = subprocess.check_output([command], shell=True)
    splitter = f"chain {chain}" + " {"
    ruleListRaw = ruleListOutput.decode("utf-8").split(splitter)
    del(ruleListRaw[0])
    ruleListRaw = ruleListRaw.split("\n")
    return ruleListRaw[1]
def dam():
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
    z = True
    while(z):
        blackList = getBlackList()
        if(len(blackList) == 0):
            print("No IPs in blacklist.")
        else:
            print("Current list of blacklisted IPs:")
            for ip in blackList:
                print(ip[0] + " ("+ip[1]+")")
        option = input("[Command@Blacklist]# ")
        if(option.lower() == ''):
            pass
        elif(option.lower() == 'add'):
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
        elif(option.lower() == 'delete'):
            x = True
            if(len(blackList) == 0):
                x = False
                print("Cannot remove from blacklist. No IPs present.")
            while(x):
                index = 0
                option = input("Enter IP or handle to remove from blacklist: ")
                for ip in blackList:
                    if(ip[0] == option):
                        x = False
                    if(ip[1] == option):
                        x = False
                    if(x):
                        index = index+1
                if(x):
                    optionList = option.split(".")
                    if(len(optionList) == 1):
                        print(f"{option} not in blacklist.")
                    else:
                        print(f"No IP connecting to handle {option}")
            confirm = input(f"Confirmation: Removing {blackList[index][0]} from blacklist: ")
            ip = blackList[index][0]
            if(confirm.lower() in ('y', 'yes')):
                os.system("nft delete rule blacklist blockIn handle "+str(blackList[index][1]))
                os.system("nft delete rule blacklist blockOut handle "+str(int(blackList[index][1])+1))
            blackList = getBlackList()
            y = True
            for heldIP in blackList:
                if(heldIP[0] == option or heldIP[1] == option):
                    y = False
            if(y):
                print(f"{ip} successfully removed from blacklist.")
            else:
                print(f"Error removing {ip} from blacklist.")
        elif(option.lower() == 'exit'):
            return
        elif(option.lower() == 'quit'):
            return "quit"
        elif(option.lower() == 'panic'):
            panic()
        else:
            printHelp()
def getBlackList():
    blackList = [[]]
    blackListOutput = subprocess.check_output(["nft -a list table blacklist"], shell=True)
    blackListRaw = blackListOutput.decode("utf-8").split("saddr ")
    del(blackListRaw[0])
    for line in blackListRaw:
        ipSplit = line.split(" ")
        itemList = []
        itemList.append(ipSplit[0])
        handleList = ipSplit[4].split("\n")
        handle = handleList[0]
        itemList.append(handle)
        blackList.append(itemList)
    del(blackList[0])
    return blackList
def addToBlackList(ip):
    tableList = getTableList()
    x = True
    for table in tableList:
        if(table == "blacklist"):
            x = False
    if(x):
        return "Blacklist table does not exist."
    os.system("nft add rule blacklist blockIn ip saddr { "+ip+" } drop")
    os.system("nft add rule blacklist blockOut ip daddr { "+ip+" } drop")
    blackList = getBlackList()
    x = True
    for entry in blackList:
        if(entry[0] == ip): 
            x = False
    if(x):
        return f"Error adding {ip} to blacklist"
    else:
        return f"{ip} successfully added to blacklist."
def removeFromBlackList(ip):
    blackList = getBlackList()
    x = True
    index = 0
    for entry in blackList:
        if(entry[0] == ip): 
            x = False
        if(x):
            index = index+1
    if(x):
        return "IP not found in blacklist."
    os.system("nft delete rule blacklist blockIn handle "+str(blackList[index][1]))
    os.system("nft delete rule blacklist blockOut handle "+str(int(blackList[index][1])+1))
    x = True
    for entry in blackList:
        if(entry[0] == ip): 
            x = False
    if(x):
        return f"{ip} successfully removed from blacklist."
    else:
        return f"Error removing {ip} from blacklist."
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
def portDefault(protocol, port):
    if(protocol == "tcp"):
        return {
            '20': 'FTP',
            '22': 'SSH',
            '25': 'SMTP',
            '53': 'DNS',
            '80': 'HTTP',
            '110': 'POP3',
            '220': 'IMAP',
            '443': 'HTTPS'
        }.get(port, "")
    elif(protocol == "udp"):
        return {
            '53': 'DNS',
            '123': 'NTP',
            '220': 'IMAP'
        }.get(port, "")
    else:
        return ""
def addOtherPorts(inputArray):
    portArray = inputArray
    commonTCP = ["20", "22", "53", "80", "443"]
    commonUDP = ["53", "123"]
    for port in commonTCP:
        if(port not in portArray):
            value = "TCP " + port + " " + portDefault("TCP", port)
            portArray.append(value)
    for port in commonUDP:
        if(port not in portArray):
            value = "UDP " + port + " " + portDefault("UDP", port)
            portArray.append(value)
def printHelp():
    print("""
Firewall interface for linux machines using nftables. Written for use by EKU's CCDC team in practice and live environments.


Command line arguments:

    -h , --help    |     Displays this help menu and exits.
    -ba (ip)       |     Adds given IP to blacklist.
    -br (ip)       |     Removes given IP from blacklist.
    -e             |     Enters expert mode, allows for more in-depth customization of nfTables.

In-Program Commands:

    help           |     Displays this help menu.
    exit           |     Exits out of current command focus and returns to the previous layer. (ex. using "exit" while in a specific chain moves the focus to the table that contains the chain)
    quit           |     Quits out of program.
    panic          |     Activates/Deactivates panic mode. Will only prompt confirmation when disabling panic mode.
    blacklist      |     Enters blacklist management menu.

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
    delete         |     Removes a stated rule from the current chain.
    list           |     Lists all rules present in selected chain, along with their handles.
    
    Blacklist Commands:
    
    add            |     Adds a new IP to the blacklist.
    delete         |     Removes an IP from the blacklist.
    
    
""")
main()