# Manual Installation Guide - Multi-Tier Application

This guide provides step-by-step instructions for manually installing and configuring each component of the multi-tier application stack without using Vagrant automation.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Network Configuration](#network-configuration)
- [1. Database Server (MariaDB)](#1-database-server-mariadb)
- [2. Memcached Server](#2-memcached-server)
- [3. RabbitMQ Server](#3-rabbitmq-server)
- [4. Application Server (Tomcat)](#4-application-server-tomcat)
- [5. Web Server (Nginx)](#5-web-server-nginx)
- [Testing the Setup](#testing-the-setup)

---

## Prerequisites

### Hardware Requirements
- **5 Virtual or Physical Machines** with the following specifications:
  - Database Server: 2 GB RAM minimum
  - Memcached Server: 900 MB RAM minimum
  - RabbitMQ Server: 600 MB RAM minimum
  - Application Server: 4 GB RAM minimum
  - Web Server: 800 MB RAM minimum

### Operating Systems
- **CentOS Stream 9** (for db01, mc01, rmq01, app01)
- **Ubuntu 22.04 LTS** (for web01)

### Network Configuration
All servers must be on the same network and able to communicate. Use the following IP addresses:

| Hostname | IP Address | Purpose |
|----------|------------|---------|
| db01 | 192.168.56.15 | MariaDB Database |
| mc01  | 192.168.56.14 | Memcached |
| rmq01  | 192.168.56.13 | RabbitMQ |
| app01 | 192.168.56.12 | Tomcat Application Server |
| web01 | 192.168.56.11 | Nginx Web Server |

### Configure Hostnames

On **all servers**, edit `/etc/hosts` file:

```bash
sudo vi /etc/hosts
```

Add these entries:

```
192.168.56.15    db01
192.168.56.14    mc01 
192.168.56.13    rmq01 
192.168.56.12    app01
192.168.56.11    web01
```

---

## 1. Database Server (MariaDB)

**Server**: db01 (192.168.56.15) - CentOS Stream 9

### Step 1: Update System and Install Packages

```bash
sudo dnf update -y && sudo git vim mariadb-server  -y
```

### Step 2: Start and Enable MariaDB Service

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### Step 3: Secure MariaDB Installation

```bash
mysql_secure_installation 
```

### Step 4: Configure Application Database

Clone the source code repository:

```bash
cd /tmp/
git clone -b Automation https://github.com/Omarh4700/Workshop.git
```

Create database and user:

```bash
sudo mysql -u root -p'admin123' -e "CREATE DATABASE IF NOT EXISTS accounts"
sudo mysql -u root -p'admin123' -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123'"
sudo mysql -u root -p'admin123' -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123'"
```

Restore database dump:

```bash
sudo mysql -u root -p'admin123' accounts <  /tmp/Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr/src/main/resources/db_backup.sql
sudo mysql -u root -p'admin123' -e "FLUSH PRIVILEGES"
```

Clean up:

```bash
rm -rf /tmp/Workshop
```

Restart MariaDB:

```bash
sudo systemctl restart mariadb
```

### Step 5: Configure Firewall

```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
```

### Verification

```bash
# Check MariaDB status
sudo systemctl status mariadb

# Test database connection
mysql -u admin -p'admin123' -h localhost accounts -e "SELECT COUNT(*) FROM user;"
```

---

## 2. Memcached Server

**Server**: mc01 (192.168.56.14) - CentOS Stream 9

### Step 1: Update System and Install Memcached

```bash
sudo dnf update -y
sudo dnf install epel-release memcached -y
```

### Step 2: Start and Enable Memcached

```bash
sudo systemctl start memcached
sudo systemctl enable memcached
```

### Step 3: Configure Memcached to Listen on All Interfaces

```bash
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached
sudo systemctl restart memcached
```

### Step 4: Configure Firewall

```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=11211/tcp --permanent
sudo firewall-cmd --add-port=11111/udp --permanent
sudo firewall-cmd --reload
```

### Step 5: Restart Memcached with Custom Ports

```bash
sudo memcached -p 11211 -U 11111 -u memcached -d
```

### Verification

```bash
# Check Memcached status
sudo systemctl status memcached

# Test Memcached connection
echo "stats" | nc 192.168.56.14 11211
```

---

## 3. RabbitMQ Server

**Server**: rmq01 (192.168.56.13) - CentOS Stream 9

### Step 1: Update System and Install Dependencies

```bash
sudo dnf update -y
sudo dnf install epel-release wget -y
```

### Step 2: Install RabbitMQ Repository

```bash
sudo dnf -y install centos-release-rabbitmq-38
```

### Step 3: Install RabbitMQ Server

```bash
sudo dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server
```

### Step 4: Enable and Start RabbitMQ

```bash
sudo systemctl enable --now rabbitmq-server
```

### Step 5: Configure Firewall

```bash
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --add-port=5672/tcp --permanent
sudo firewall-cmd --reload
```

### Step 6: Create RabbitMQ User

```bash
sudo rabbitmqctl add_user guest guest
sudo rabbitmqctl set_user_tags guest administrator
sudo rabbitmqctl set_permissions -p / guest ".*" ".*" ".*"
```

### Step 7: Restart RabbitMQ

```bash
sudo systemctl restart rabbitmq-server
```

### Verification

```bash
# Check RabbitMQ status
sudo systemctl status rabbitmq-server

# List RabbitMQ users
sudo rabbitmqctl list_users

# Check if RabbitMQ is listening on port 5672
sudo netstat -tulpn | grep 5672
```

---

## 4. Application Server (Tomcat)

**Server**: app01 (192.168.56.12) - CentOS Stream 9

### Step 1: Update System and Install Dependencies

```bash
sudo dnf update -y
sudo dnf install java-11-openjdk java-11-openjdk-devel git maven wget -y
```

### Step 2: Download and Install Tomcat

```bash
cd /tmp/
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz
tar xzvf apache-tomcat-9.0.75.tar.gz
```

### Step 3: Set Up Tomcat User and Permissions

```bash
sudo useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat
sudo mkdir -p /usr/local/tomcat
sudo cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/
sudo chown -R tomcat:tomcat /usr/local/tomcat
```

### Step 4: Create Systemd Service for Tomcat

create `tomcat.service`

```bash
sudo vim /etc/systemd/system/tomcat.service
```
> copy the following file into `/etc/systemd/system/tomcat.service`

```bash
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
```

### Step 5: Enable and Start Tomcat

```bash
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat
```

### Step 6: Clone and Build the Application

```bash
cd /tmp/
git clone -b Vagrant https://github.com/Omarh4700/Workshop.git
cd Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr
```

### Step 7: Update Database Credentials

```bash
sed -i 's/^jdbc\.username=.*/jdbc.username=admin/' src/main/resources/application.properties
sed -i 's/^jdbc\.password=.*/jdbc.password=admin123/' src/main/resources/application.properties
```

### Step 8: Build the Application

```bash
mvn clean install
```

### Step 9: Deploy the WAR File

```bash
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo chown -R tomcat:tomcat /usr/local/tomcat/webapps
sudo systemctl start tomcat
```

### Step 10: Disable Firewall (for testing)

**Note**: In production, configure specific firewall rules instead of disabling it.

```bash
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl restart tomcat
```

### Verification

```bash
# Check Tomcat status
sudo systemctl status tomcat

# Check Tomcat logs
sudo tail -f /usr/local/tomcat/logs/catalina.out

# Test if application is responding
curl http://localhost:8080
```

---

## 5. Web Server (Nginx)

**Server**: web01 (192.168.56.11) - Ubuntu 22.04

### Step 1: Update System and Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
```

### Step 2: Generate Self-Signed SSL Certificate

Create the SSL setup script:

```bash
cat > ~/ssl_setup.sh <<'EOT'
#!/bin/bash
# Create directory for SSL certificates
mkdir -p ~/ssl

# Generate SSL certificate and key
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ~/ssl/nginx.key \
  -out ~/ssl/nginx.crt \
  -subj "/C=EG/ST=Cairo/L=Cairo/O=socialapp/CN=app01"

echo "✅ SSL certificate and key generated successfully in the 'ssl/' directory."
EOT
```

Make it executable and run it:

```bash
chmod +x ~/ssl_setup.sh
./ssl_setup.sh
```

### Step 3: Create Nginx Configuration

```bash
sudo tee /etc/nginx/sites-available/socialapp > /dev/null <<'EOT'
# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name app01;

    return 301 https://$host$request_uri;
}

# HTTPS server for app01 (proxy to backend)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name app01;

    ssl_certificate /home/vagrant/ssl/nginx.crt;
    ssl_certificate_key /home/vagrant/ssl/nginx.key;

    location / {
        proxy_pass http://app01:8080;
    }
}
EOT
```

**Note**: If your username is different from `vagrant`, update the SSL certificate paths accordingly:

```bash
# Replace 'vagrant' with your actual username
sudo sed -i "s|/home/vagrant/|/home/$(whoami)/|g" /etc/nginx/sites-available/socialapp
```

### Step 4: Enable the Site

```bash
sudo rm -rf /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/socialapp /etc/nginx/sites-enabled/socialapp
```

### Step 5: Test and Start Nginx

```bash
# Test Nginx configuration
sudo nginx -t

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl restart nginx
```

### Verification

```bash
# Check Nginx status
sudo systemctl status nginx

# Test from web01 server
curl -k https://localhost

# Check Nginx error logs if issues occur
sudo tail -f /var/log/nginx/error.log
```

---

## Testing the Setup

### 1. Test Individual Services

**From any server with network access:**

```bash
# Test MariaDB
mysql -h 192.168.56.15 -u admin -p'admin123' accounts -e "SELECT COUNT(*) FROM user;"

# Test Memcached
echo "stats" | nc 192.168.56.14 11211

# Test RabbitMQ
telnet 192.168.56.13 5672

# Test Tomcat
curl http://192.168.56.12:8080

# Test Nginx
curl -k https://192.168.56.11
```

### 2. Test from Browser

From your workstation:

1. Open browser and navigate to: `https://app01`

2. Accept the self-signed certificate warning:
   - Click **Advanced**
   - Click **Accept the Risk and Continue**

3. Login with credentials:
   - **Username**: `admin_vp`
   - **Password**: `admin_vp`

4. Test functionality:
   - Click **"All Users"** to verify database connection
   - Click **"RabbitMQ"** to test message queue connection
   - Try creating a new user to test full stack

### 3. Check Service Connectivity

**From app01 server:**

```bash
# Test database connectivity
mysql -h db01 -u admin -p'admin123' accounts -e "SHOW TABLES;"

# Test Memcached connectivity
telnet mc01 11211

# Test RabbitMQ connectivity
telnet rmq01 5672
```

---

## Troubleshooting Common Issues

### MariaDB Issues

**Problem**: Cannot connect to MariaDB from app01

```bash
# On db01, check if MariaDB is listening on all interfaces
sudo netstat -tulpn | grep 3306

# If only listening on 127.0.0.1, edit MariaDB config
sudo vi /etc/my.cnf.d/mariadb-server.cnf

# Add or modify:
[mysqld]
bind-address = 0.0.0.0

# Restart MariaDB
sudo systemctl restart mariadb
```

### Memcached Issues

**Problem**: Memcached not responding

```bash
# Check if memcached is running
sudo systemctl status memcached

# Check listening ports
sudo netstat -tulpn | grep memcached

# Restart memcached
sudo systemctl restart memcached
```

### RabbitMQ Issues

**Problem**: RabbitMQ connection refused

```bash
# Check RabbitMQ status
sudo systemctl status rabbitmq-server

# Check RabbitMQ logs
sudo journalctl -u rabbitmq-server -f

# Restart RabbitMQ
sudo systemctl restart rabbitmq-server
```

### Tomcat Issues

**Problem**: Application not deploying

```bash
# Check Tomcat logs
sudo tail -f /usr/local/tomcat/logs/catalina.out

# Check if WAR file exists
ls -lh /usr/local/tomcat/webapps/

# Redeploy application
sudo systemctl stop tomcat
sudo rm -rf /usr/local/tomcat/webapps/ROOT*
sudo cp /tmp/sourcecodeseniorwr/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
sudo chown -R tomcat:tomcat /usr/local/tomcat/webapps
sudo systemctl start tomcat
```

### Nginx Issues

**Problem**: SSL certificate errors

```bash
# Check SSL certificate paths
sudo nginx -t

# Verify certificate files exist
ls -lh ~/ssl/

# Regenerate certificates if needed
rm -rf ~/ssl
./ssl_setup.sh

# Update Nginx config with correct paths
sudo vi /etc/nginx/sites-available/socialapp
```

---

## Security Considerations

⚠️ **Important**: This setup is for development/testing only. For production:

1. **Change all default passwords**
2. **Use proper SSL certificates** (Let's Encrypt or commercial CA)
3. **Configure SELinux/AppArmor** properly
4. **Implement proper firewall rules** (don't disable firewalld)
5. **Regular security updates**
6. **Implement backup strategies**
7. **Use strong authentication** (not guest/guest for RabbitMQ)
8. **Restrict database access** to specific hosts
9. **Enable HTTPS only** for all external access
10. **Implement monitoring and logging**

---

## Next Steps

After successful installation:

1. Configure monitoring (Prometheus, Grafana)
2. Set up log aggregation (ELK Stack)
3. Implement backup automation
4. Configure SSL certificates from trusted CA
5. Harden security configurations
6. Document your specific customizations
7. Create disaster recovery procedures

---

## Additional Resources

- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Memcached Documentation](https://memcached.org/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

## Support

If you encounter issues during manual installation:

1. Check service logs (journalctl or specific log files)
2. Verify network connectivity between servers
3. Ensure all prerequisites are met
4. Confirm correct IP addresses and hostnames
5. Review firewall rules
6. Check SELinux status if enabled