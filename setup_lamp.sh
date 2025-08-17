#!/bin/bash
sudo apt update
sudo apt upgrade
sudo apt install git
sudo apt install openssh-server
sudo apt install apache2
sudo ufw app list
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"
sudo apt install mysql-server
sudo mysql_secure_installation
sudo apt install php libapache2-mod-php php-mysql -y
sudo systemctl restart apache2
sudo apt-get install phpmyadmin php-mbstring php-php-gettext -y
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo systemctl restart apache2

echo "LAMP stack installed successfully!"
echo "Use the following commands to check the status of the services:"  
echo "sudo systemctl status apache2"
echo "sudo nano /etc/apache2/apache2.conf"
echo "sudo nano /etc/php/8.3/apache2/php.ini"
echo "Thank You" 
echo "www.dhakamicro.com"
