#!/bin/bash
# Stop on error
set -e
# Setting database password
MARIADB_PASS='admin123'

echo "  |Starting MariaDB Server Setup...| "
# installing mariadb-server and other required packages
sudo dnf update -y && sudo dnf install epel-release git zip unzip mariadb-server -y

# starting & enabling mariadb-server
echo "  |Starting & enabling MariaDB Service...| "
sudo systemctl start mariadb
sudo systemctl enable mariadb
##############################################
# Secure MySQL Root & Remove Unnecessary Stuff
##############################################
echo "  |Securing MariaDB Installation...| "
# 1. Set the root password
# Using mysqladmin
sudo mysqladmin -u root password "$MARIADB_PASS"
# 2. Remove anonymous users
sudo mysql -u root -p"$MARIADB_PASS" -e "DELETE FROM mysql.user WHERE User='';"
# 3. Disallow remote root login
sudo mysql -u root -p"$MARIADB_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# 4. Remove the test database and access to it
sudo mysql -u root -p"$MARIADB_PASS" -e "DROP DATABASE IF EXISTS test;"
sudo mysql -u root -p"$MARIADB_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';"
# 5. Reload privilege tables
sudo mysql -u root -p"$MARIADB_PASS" -e "FLUSH PRIVILEGES"
###########################################
# Configure Application Database
###########################################
echo "  |Cloning Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr repository...| "
cd /tmp/
git clone -b Vagrant https://github.com/Omarh4700/Workshop.git
###########################################################
# Create Database and User
echo "  |Configuring MariaDB Database...| "
# Create application DB
sudo mysql -u root -p"$MARIADB_PASS" -e "CREATE DATABASE IF NOT EXISTS accounts"
# Create admin user for the app
sudo mysql -u root -p"$MARIADB_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p"$MARIADB_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"
# Restore DB dump
sudo mysql -u root -p"$MARIADB_PASS" accounts < /tmp/Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr/src/main/resources/db_backup.sql
sudo mysql -u root -p"$MARIADB_PASS" -e "FLUSH PRIVILEGES"
echo "  |MariaDB Database Configured Successfully.| "

# Cleaning up
rm -rf /tmp/Workshop
# Restart mariadb-server
sudo systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
echo "  |Configuring Firewall for MariaDB...| "
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
echo "  |Firewall Configured for MariaDB Successfully.| "
echo "  |MariaDB Server Setup Completed...| "
