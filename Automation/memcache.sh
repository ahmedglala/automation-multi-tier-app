#!/bin/bash
# Stop on error
set -e

echo "  |Starting Memcached Server Setup...| "
# installing memcached package
echo "  |Installing Memcached package...| "
sudo dnf update && sudo dnf install epel-release memcached -y
# starting & enabling memcached service
sudo systemctl start memcached
sudo systemctl enable memcached
sudo systemctl status memcached
# configuring memcached to listen on all interfaces
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
# configuring firewall for memcached
echo "  |Configuring Firewall for Memcached...| "
sudo systemctl start firewalld
sudo systemctl enable firewalld
# opening ports 11211/tcp and 11111/udp
echo "  |Opening Ports 11211/tcp and 11111/udp...| "
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --add-port=11111/udp --permanent
sudo firewall-cmd --reload
# restarting memcached with custom ports
echo "  |Restarting Memcached with Custom Ports...| "
sudo memcached -p 11211 -U 11111 -u memcached -d
echo "  |Memcached Server Setup Completed.| "