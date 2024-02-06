key_path="/var/www/html/prestashop/config/settings.inc.php"
key="$(cat $settings_path | grep "_COOKIE_KEY_" | cut -d ',' -f2 | tr -d " ,');")"
pass="changeme"
query="UPDATE ps_employee SET passwd = MD5('$key+$pass') WHERE firstname = 'Greg';"

mysql -u "root" -p "changeme" "prestashop" -e "$SQL_QUERY"
