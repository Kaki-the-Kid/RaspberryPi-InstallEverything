#! /bin/bash

# Step 1: Run this as root/superuser, do sudo su or sudo
# Step 2: Wait for the script to run

echo "Shell script to install apache/mysql/php/phpmyadmin"
#wordpress into an EC2 instance of Amazon AMI Linux."
echo "Please run as root, if you're not, choose N now and enter 'sudo su' before running the script."
echo "Run script? (y/n)"

read -e run
if [ "$run" == "n" ] ; then
	echo “chicken...”
	exit
else

# First we upgrade everything
sudo apt-get update
sudo apt-get upgrade
sudo apt-get auto-remove

# we'll install 'expect' to input keystrokes/y/n/passwords
# See examples on: https://phoenixnap.com/kb/linux-expect
sudo apt install expect -y

# Install Apache2
sudo apt install apache2 -y

# Start Apache - should start by it self
chromium-browser http://localhost/

echo "if you didn't receive error, you can see your default website at:"
hostname -I

# Install PHP 8.2
# Ex. https://lindevs.com/install-php-on-raspberry-pi/
echo "Installing php version 8.2 incl. mod-lib for Apache"

echo "Connect to Raspberry Pi via SSH and execute command to download GPG key:"
sudo wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

echo "Adding PHP repository:"
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list

echo "Update the package lists:"
sudo apt update -y

echo "Next, install PHP 8.2 with command line interface (CLI):"
sudo apt install -y php8.2-common php8.2-cli

echo "checking php install"
php --version

echo "You can install extensions in php, with:"
echo "sudo apt install -y php8.2-<extension_name>"
echo "Installing extensions: Curl, gd, mbstring, xml and zip"
sudo apt install -y php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip

echo "Installed php extensions:"
php -m

echo "PHP integration with MySQL or MariaDB"
sudo apt install -y php8.2-mysql

echo "PHP integration with Apache"
sudo apt install -y libapache2-mod-php8.2

# Restart Apache
echo "Restarting Apache server ..."
sudo service apache2 restart

sudo touch /var/www/html/info.php
sudo chown pi /var/www/html/info.php
sudo echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

# Start Apache - should start by it self
chromium-browser http://localhost/info.php

# Install MySQL
# https://pimylifeup.com/raspberry-pi-mysql/
echo "installing MySQL as MariaBD"
sudo apt install -y mariadb-server

# Start MySQL
sudo 

service mysqld start

# Create a database named blog
sudo mysqladmin -uroot -s drop wordpress_db create wordpress_db

# Secure database
# non interactive mysql_secure_installation with a little help from expect.
#SECURE_MYSQL=$(expect -c "
 
#set timeout 10
#spawn mysql_secure_installation
sudo mysql_secure_installation
 
#expect \"Enter current password for root (enter for none):\"
#send \"\r\"
 
#expect \"Change the root password?\"
#send \"y\r\"
#expect \"New password:\"
#send \"password\r\"
#expect \"Re-enter new password:\"
#send \"password\r\"
#expect \"Remove anonymous users?\"
#send \"y\r\"
 
#expect \"Disallow root login remotely?\"
#send \"y\r\"
# 
#expect \"Remove test database and access to it?\"
#send \"y\r\"
 
#expect \"Reload privilege tables now?\"
#send \"y\r\"
 
#expect eof
#")

#echo "$SECURE_MYSQL"



#********************************************
# WordPress
#********************************************
# If the script won't install properly, there a guide on:
# https://pimylifeup.com/raspberry-pi-wordpress/

# Change directory to web root
cd /var/www/html

# Download Wordpress
sudo wget http://wordpress.org/latest.tar.gz

# Extract Wordpress
sudo tar -xzvf latest.tar.gz

# Rename wordpress directory to blog
sudo mv wordpress blog

# Change directory to blog
cd /var/www/html/blog/

# Making group www-data and put pi user in it
sudo usermod -a -G www-data pi

# Setting the right permission for group and user
sudo chown -R -f www-data:www-data /var/www/html

# Create a WordPress config file 
mv wp-config-sample.php wp-config.php

#set database details with perl find and replace
sudo sed -i "s/database_name_here/blog/g" /var/www/html/blog/wp-config.php
sudo sed -i "s/username_here/root/g" /var/www/html/blog/wp-config.php
sudo sed -i "s/password_here/password/g" /var/www/html/blog/wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
sudo chmod 777 wp-content/uploads

#remove wp file
sudo rm /var/www/html/latest.tar.gz

echo "Ready, go to http://'your ec2 url'/blog and enter the blog info to finish the installation."

#********************************************
# PHPMyAdmin
#********************************************
# Install phpmyadmin
# Normally one would use following command
# sudo apt install phpmyadmin
# But that gives you a older version
# We want the latest

# Change dir and download latest version
cd ~/Downloads/
wget -O phpmyadmin.tar.gz https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz

# Create a new directory where phpMyAdmin will be stored and extract tar.gz file:
sudo mkdir /usr/share/phpmyadmin
sudo tar xf phpmyadmin.tar.gz --strip-components=1 -C /usr/share/phpmyadmin

# The tar.gz file is no longer required, we can remove it:
rm -rf phpmyadmin.tar.gz

# Create directory for phpMyAdmin temporary files and make www-data user as owner:
sudo mkdir -p /var/lib/phpmyadmin/tmp
sudo chown -R www-data:www-data /var/lib/phpmyadmin

# The phpMyAdmin provides a sample configuration file. Create a copy of this file named config.inc.php:
sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php

# Using text editor open a configuration file:
echo "Replace the line: $cfg['blowfish_secret'] = '';"
echo "with: $cfg['blowfish_secret'] = 'RV%Hg)2_Bt_)[%mAC24;#$Wu+)3du9}q';"
sudo nano /usr/share/phpmyadmin/config.inc.php

# This secret passphrase will be used for encryption. Also we need to specify 
# temporary directory where phpMyAdmin can store cache. Add the following line 
# to the end of a file:
echo "Puth this at the end of the file"
echo "$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" > /usr/share/phpmyadmin/config.inc.php

# Now we need to configure Apache. Create Apache configuration file for 
# phpMyAdmin:
sudo touch /etc/apache2/conf-available/phpmyadmin.conf
sudo echo "Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>" > /etc/apache2/conf-available/phpmyadmin.conf

# Enable the phpMyAdmin site:
sudo a2enconf phpmyadmin.conf

# Run the following command to restart Apache service:
sudo service apache2 restart


#********************************************
# Install FTP Server on Raspberry Pi
#********************************************
# To install FTP server, run below command
sudo apt install -Y pure-ftpd

# Once the FTP server is installed, you can try to connect to FTP server 
# using FileZilla software
# Use the Raspberry Pi IP Address and credentials to connect
# In my case the IP Address is 192.168.1.5 and the login credentials is 
# pi as username and raspberry as password
# No need to type anything for port, because we are using the default port, 
# which is 21
# To upload our web page or web application to raspberry pi we need to have 
# root access to that folder. Run below command
sudo -i
# Now move to that html folder 
cd /var/www/html/

# Create new folder mkdir sa. I want to upload my web app to folder sa
# go back to root folder. Run command 
cd ..

# Provide enough access for FTP to this folder 
chmod 777 /var/www/html/sa/

# Restart FTP server. 
sudo service pure-ftpd restart

# Our FTP account should have enough access to upload files to this folder now
# Go to FileZilla and reconnect to Raspberry Pi.
# Once we are connected again to Raspberry Pi find your folder on both raspberry 
# pi and local computer
# Upload your web page files to raspberry pi
# I am going to upload my home automation web application code to raspberry pi 
# now.
#I have published this in Github here


#********************************************
# Install Samba Server on Raspberry Pi
#********************************************
# Run command 
sudo apt install -y samba samba-common-bin

# Type Y and hit enter key when you find any confirmation message
# Now create a folder which should be set as shared folder. For that 
# run below command
mkdir /home/pi/shared

# Next we need to provide full access to this fodler.
# Run below command and edit the smb configuration file to provide full access


# Now you can see the file open in cmd.
echo "Go to the end of that file and then paste below text"
echo "[Public SDCard]
Comment = Public Folder from SDCard
Path = /home/pi/shared
Browseable = yes
Writeable = Yes
only guest = no
create mask = 0644
directory mask = 0755
force create mask = 0644
force directory mask = 0755
force user = root
force group = root
Public = yes
Guest ok = yes
read only = no"

read "ok"

sudo nano /etc/samba/smb.conf

# Finally we need to create a user for Samba. Run below command
sudo smbpasswd -a pi

# Finally, before we connect to our Raspberry Pi Samba share, we need to 
# restart the samba service so that it loads in our configuration changes
sudo systemctl restart smbd



fi

