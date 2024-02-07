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

# Secure the mysql installation
query="CREATE USER 'sysadmin'@'localhost' IDENTIFIED BY '$prestashop_new_db_user_password';"
info "Creating new DB user"
mysql -u"root" -p"" -e"$query" --verbose

info "Starting the MySQL secure installation script..."
mysql_secure_installation

# The password of prestashop users is salted with the cookie key. Save the cookie key to a variable and change the password.
key_path="/var/www/html/prestashop/config/settings.inc.php"
key="$(cat $key_path | grep "_COOKIE_KEY_" | cut -d ',' -f2 | tr -d " ,');")"
query="UPDATE ps_employee SET passwd = MD5('$key$prestashop_admin_password') WHERE firstname = 'Greg';"

info "Resetting prestashop DB_USER and DB_PASSWD"
sed -i "/_DB_USER_\$/c\define('_DB_USER_', 'sysadmin');" /var/www/html/prestashop/config/settings.inc.php
sed -i "/_DB_PASSWD_\$/c\define('_DB_PASSWD_', '$prestashop_new_db_user_password');" /var/www/html/prestashop/config/settings.inc.php

info "Changing prestashop admin password"
mysql -u"sysadmin" -p"$prestashop_new_db_user_password" -D"prestashop" -e"$query" --verbose

exit 0 # Script ended successfully

