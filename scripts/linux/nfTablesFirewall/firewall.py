import os
import subprocess
import sys
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
    
    add            |     Adds a new chain to the selected table.
    chain          |     Changes command focus to a specific chain within the table.
    
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
        elif(option.lower() in ('chain')):
            
def chainCommand(table, chain):
    x = True
    while(x):
        
def getTableList():
    tableList = []
    tableOutput = subprocess.check_output(["nft", "list tables"])
    tableListRaw = tableOutput.decode("utf-8").split("\n")
    for line in tableListRaw:
        lineList = line.split(" ")
        tableList.append(lineList[-1])
    return tableList
main()