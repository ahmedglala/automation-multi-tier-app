#!/bin/bash
# Stop on error
set -e

#setting variables
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz"
REPO="https://github.com/Omarh4700/Workshop.git"
WEBAPPS="/usr/local/tomcat/webapps"
APP_PROPERTIES="src/main/resources/application.properties"
# Updating system and installing dependencies
echo "  |Updating system and installing dependencies...| "

sudo dnf update && sudo dnf install java-11-openjdk java-11-openjdk-devel git maven wget -y

cd /tmp/
# Downloading and installing Tomcat
echo "  |Downloading and installing Tomcat...| "
wget $TOMURL -O apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz
# Setting up Tomcat user and permissions
echo "  |Setting up Tomcat user and permissions...| "
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
sudo mkdir -p /usr/local/tomcat
sudo cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat

# Creating systemd service file for Tomcat
echo "  |Creating systemd service file for Tomcat...| "
cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk"
Environment="CATALINA_PID=/usr/local/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/usr/local/tomcat"
Environment="CATALINA_BASE=/usr/local/tomcat"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

ExecStart=/usr/local/tomcat/bin/startup.sh
ExecStop=/usr/local/tomcat/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target

EOT

##### 

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
cd /tmp/

# Deploying  application
echo "  |Deploying  application...| "
git clone -b Vagrant $REPO
cd Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr

# Updating database credentials in application.properties
echo "  |Updating database credentials in application.properties...| "
sed -i 's/^jdbc\.username=.*/jdbc.username=admin/' $APP_PROPERTIES
sed -i 's/^jdbc\.password=.*/jdbc.password=admin123/' $APP_PROPERTIES

# making the build
echo "  |Building the application...| "
mvn clean install
sudo systemctl stop tomcat
sleep 20 
# Deploying the WAR file
echo "  |Deploying the WAR file...| "
rm -rf $WEBAPPS/ROOT*
cp target/vprofile-v2.war $WEBAPPS/ROOT.war
sudo chown -R tomcat:tomcat $WEBAPPS
sudo systemctl start tomcat
sleep 20
# Configuring firewall for Tomcat
echo "  |Configuring firewall for Tomcat...| "
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl restart tomcat