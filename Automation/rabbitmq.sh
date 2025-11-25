#!/bin/bash


# Updating system
echo "  |Updating system...| "
sudo dnf update -y
sudo dnf install epel-release wget -y

# Installing RabbitMQ repository
echo "  |Installing RabbitMQ repository...| "
sudo dnf -y install centos-release-rabbitmq-38

# Installing RabbitMQ server
echo "  |Installing RabbitMQ server...| "
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server

# Enabling & starting RabbitMQ
echo "  Enabling & starting RabbitMQ...| "
sudo systemctl enable --now rabbitmq-server
#####
echo "|  Configuring firewall...|  "
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=5672/tcp --permanent
sudo firewall-cmd --reload
# Opening firewall port 5672
echo "  |Creating RabbitMQ user (guest)...| "
sudo rabbitmqctl add_user guest guest
sudo rabbitmqctl set_user_tags guest administrator
sudo rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"

# Restarting RabbitMQ
echo "  |Restarting RabbitMQ...| "
sudo systemctl restart rabbitmq-server

# Final status check
echo "  |RabbitMQ installation completed!| "
sudo systemctl status rabbitmq-server
echo "  |RabbitMQ is running on port 5672.| "
echo "  |Firewall configured to allow RabbitMQ traffic on port 5672.| "
echo "  |RabbitMQ User 'guest' created with administrator privileges.| "
echo "  |RabbitMQ Server Setup Completed Successfully.| "