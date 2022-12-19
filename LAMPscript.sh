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

fi
