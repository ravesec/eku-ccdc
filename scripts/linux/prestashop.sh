#!/bin/bash

# Author: Raven Dean
# prestashop.sh
#
# Description: Script to harden weak installs of prestashop.
#
# Dependencies: ../../config_files/ekurc
# Created: 02/06/2024
# Usage: <./prestashop.sh>

# Edit these as required.
script_name="prestashop.sh"
usage="./$script_name"

sql_pass="changeme"

# Import environment variables
. ../../config_files/ekurc
if [ "$EUID" -ne 0 ] # Superuser requirement. Echo the error to stderr and return exit code 1.
then error "This script must be ran as root!"
    exit 1
fi

# Check for the correct number of arguments
if [ "$EUID" -gt 0 ]
then error $usage
    exit 1
fi

# Set the mysql root password
mysql -u root<<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$sql_pass';
FLUSH PRIVILEGES;
EOF

# Secure the mysql installation
info "Starting the MySQL secure installation script..."
mysql_secure_installation

# The password of prestashop users is salted with the cookie key. Save the cookie key to a variable and change the password.
key_path="/var/www/html/prestashop/config/settings.inc.php"
key="$(cat $key_path | grep "_COOKIE_KEY_" | cut -d ',' -f2 | tr -d " ,');")"
query="UPDATE ps_employee SET passwd = MD5('$key$(ask_password)') WHERE firstname = 'Greg';"

mysql -u"root" -p"$sql_pass" -D"prestashop" -e"$query" --verbose

exit 0 # Script ended successfully

