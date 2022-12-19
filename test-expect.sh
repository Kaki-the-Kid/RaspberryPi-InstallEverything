#!/usr/bin/expect

# Notes on expect
# https://phoenixnap.com/kb/linux-expect
# https://tecadmin.net/prompt-user-input-in-linux-shell-script/
# https://www.ibm.com/docs/en/zos/2.2.0?topic=keyboard-escape-sequences-control-characters


# Secure database
# non interactive mysql_secure_installation with a little help from expect.
SECURE_MYSQL=$(expect -c "
 
set timeout 10
spawn mysql_secure_installation
 
expect \"Enter current password for root (enter for none):\"
send \"\r\"
expect \"Change the root password?\"
send \"y\r\"
expect \"New password:\"
send \"password\r\"
expect \"Re-enter new password:\"
send \"password\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
 
expect \"Disallow root login remotely?\"
send \"y\r\"
 
expect \"Remove test database and access to it?\"
send \"y\r\"
 
expect \"Reload privilege tables now?\"
send \"y\r\"
 
expect eof
")
 
echo "$SECURE_MYSQL"
