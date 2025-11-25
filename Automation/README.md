# Multi-Tier Web Application - Automated Deployment

A complete multi-tier web application stack deployed using Vagrant and VirtualBox, featuring automated provisioning of all services including web server, application server, database, message queue, and caching layer.

## Architecture Overview

This project sets up a 5-VM infrastructure that mimics a production-grade multi-tier application:

```
┌─────────────────────────────────────────────────────────────┐
│                        web01 (Nginx)                        │
│                   192.168.56.11 (Ubuntu)                    │
│              SSL Termination & Reverse Proxy                │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                    app01 (Tomcat 9)                         │
│                  192.168.56.12 (CentOS)                     │
│                   Java Web Application                      │
└──────┬──────────────┬──────────────┬───────────────────────┘
       │              │              │
   ┌───▼───┐     ┌────▼────┐    ┌───▼────┐
   │ db01  │     │  mc01   │    │ rmq01  │
   │MariaDB│     │Memcached│    │RabbitMQ│
   │.56.15 │     │ .56.14  │    │ .56.13 │
   └───────┘     └─────────┘    └────────┘
```

## Components

| VM Name | Service | OS | IP Address | Memory | Purpose |
|---------|---------|----|-----------:|-------:|---------|
| web01 | Nginx | Ubuntu 22.04 | 192.168.56.11 | 800 MB | Web server with SSL and reverse proxy |
| app01 | Tomcat 9 | CentOS Stream 9 | 192.168.56.12 | 800 MB | Java application server |
| db01 | MariaDB | CentOS Stream 9 | 192.168.56.15 | 600 MB | Database server |
| mc01 | Memcached | CentOS Stream 9 | 192.168.56.14 | 600 MB | Caching layer |
| rmq01 | RabbitMQ | CentOS Stream 9 | 192.168.56.13 | 600 MB | Message queue |

## Prerequisites

Before you begin, ensure you have the following installed:

- **VirtualBox** (6.1 or later)
- **Vagrant** (2.2 or later)
- **vagrant-hostmanager plugin**: `vagrant plugin install vagrant-hostmanager`
- At least **8 GB RAM** available for VMs
- At least **20 GB** free disk space

## Quick Start

### 1. Clone or Download the Project

```bash
git clone -b Automation https://github.com/Omarh4700/Workshop.git
cd Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr
```

### 2. Start All VMs

```bash
vagrant up
```

This will:
- Create and provision all 5 VMs
- Install and configure all services automatically
- Set up networking and firewall rules
- Deploy the application

**Note**: Initial setup takes 15-30 minutes depending on your internet speed.

### 3. Access the Application

Once provisioning is complete:
- **Access the application**:
   - Open your browser and navigate to: `https://app01`
   - You'll see a security warning (self-signed certificate) - accept it to proceed

## Project Structure

```
.
├── Vagrantfile           # VM definitions and configuration
├── nginx.sh              # Nginx provisioning script
├── tomcat.sh             # Tomcat and app deployment script
├── mysql.sh              # MariaDB setup and database initialization
├── memcache.sh           # Memcached configuration
├── rabbitmq.sh           # RabbitMQ setup
└── README.md             # This file
```

## Default Credentials

### MariaDB
- **Root Password**: `admin123`
- **Database**: `accounts`
- **User**: `admin`
- **Password**: `admin123`

### RabbitMQ
- **User**: `guest`
- **Password**: `guest`
- **Management Port**: 5672

## Service Ports

| Service | Port | Protocol | Access |
|---------|------|----------|--------|
| Nginx | 80 | HTTP | Redirects to HTTPS |
| Nginx | 443 | HTTPS | Public access |
| Tomcat | 8080 | HTTP | Internal only |
| MariaDB | 3306 | TCP | Internal only |
| Memcached | 11211 | TCP | Internal only |
| Memcached | 11111 | UDP | Internal only |
| RabbitMQ | 5672 | TCP | Internal only |

## Vagrant Commands

### Manage All VMs
```bash
# Start all VMs
vagrant up

# Stop all VMs
vagrant halt

# Restart all VMs
vagrant reload

# Destroy all VMs
vagrant destroy

# Check status of all VMs
vagrant status

# SSH into any VM
vagrant ssh <vm-name>
```

### Manage Individual VMs
```bash
# Start specific VM
vagrant up web01

# Reload with provisioning
vagrant reload app01 --provision

# SSH into specific VM
vagrant ssh db01
```

## Troubleshooting

### Application Not Loading
1. Check all VMs are running: `vagrant status`
2. Verify Tomcat is running: `vagrant ssh app01 -c "sudo systemctl status tomcat"`
3. Check Nginx status: `vagrant ssh web01 -c "sudo systemctl status nginx"`

### Database Connection Issues
```bash
# SSH into app server
vagrant ssh app01

# Check database connectivity
mysql -h db01 -u admin -padmin123 accounts
```

### Service-Specific Logs
```bash
# Tomcat logs
vagrant ssh app01 -c "sudo tail -f /usr/local/tomcat/logs/catalina.out"

# Nginx logs
vagrant ssh web01 -c "sudo tail -f /var/log/nginx/error.log"

# MariaDB logs
vagrant ssh db01 -c "sudo tail -f /var/log/mariadb/mariadb.log"
```

### Reset Individual Service
```bash
# Re-provision specific VM
vagrant destroy db01 -f && vagrant up db01
```

## Security Notes

⚠️ **This setup is for development/testing purposes only**

- Self-signed SSL certificates are used
- Default passwords are hardcoded
- Firewall rules allow broad access
- Some services (like MariaDB) accept remote connections

**For production use**, ensure you:
- Use proper SSL certificates
- Change all default passwords
- Implement proper firewall rules
- Enable SELinux/AppArmor
- Set up monitoring and logging
- Implement backup strategies

## Tech Stack Details

- **Java**: OpenJDK 11
- **Build Tool**: Maven
- **Application Server**: Apache Tomcat 9.0.75
- **Database**: MariaDB (MySQL fork)
- **Web Server**: Nginx with HTTP/2
- **Caching**: Memcached
- **Message Queue**: RabbitMQ 3.8
- **Provisioning**: Shell scripts

---

## Testing the Application

### Initial Setup for Testing

Once all VMs are running, you can verify the application is working correctly by following these steps:

#### 1. Verify All VMs Are Running

```bash
vagrant status
```

All five VMs should show "running (virtualbox)" status:

<img width="507" height="208" alt="vagrant status" src="https://github.com/user-attachments/assets/e02800b0-52c3-4bac-ab51-0469737f8e1d" />

#### 2. Access the Application

**Important**: Since we're using a self-signed SSL certificate, you'll need to accept the security warning.

1. Open your browser and navigate to: `https://192.168.56.11/`

2. You'll see a security warning about the self-signed certificate:
   - Click **Advanced** (or similar option depending on your browser)
   - Click **Accept the Risk and Continue** (Firefox) or **Proceed to 192.168.56.11** (Chrome)

3. You should see the application's login page

#### 3. Login to the Application

Use the following credentials to login:

- **Username**: `admin_vp`
- **Password**: `admin_vp`

<img width="1553" height="862" alt="Welcome page " src="https://github.com/user-attachments/assets/b7de3769-89f5-452d-a845-567ce861ce05" />

#### 4. Test Database Connection - View All Users

After logging in, test the database connectivity:

1. Click on the **"All Users"** button in the navigation
2. You should see a list of users from the MariaDB database
3. This confirms the connection between Tomcat (app01) and MariaDB (db01) is working

<img width="1548" height="858" alt="User list " src="https://github.com/user-attachments/assets/534741be-6fd1-455d-abf8-b847932c16ba" />


Sample users you should see:
- Hibo Prince (ID: 4)
- Aejaaz Habeeb (ID: 5)
- Jackie (ID: 6)
- admin_vp (ID: 7)
- And more...

#### 5. Test RabbitMQ Connection

To verify the message queue is working:

1. Navigate to the **"RabbitMQ"** section or button
2. Click on **"Test RabbitMQ"** or similar option
3. You should see a confirmation message: **"Rabbitmq initiated"**
4. The page will show connection details:
   - Generated 2 Connections
   - 6 Channels, 1 Exchange, and 2 Queues

<img width="1553" height="861" alt="RabbitMQ" src="https://github.com/user-attachments/assets/abc077ee-ddc1-41f1-b026-179dce74ed57" />

This confirms the connection between Tomcat (app01) and RabbitMQ (rmq01) is functioning properly.

#### 6. Test User Registration (Optional)

You can also test creating a new user:

1. Click on **"SIGN UP"** in the navigation
2. Fill in the registration form with your details
3. Submit the form
4. The new user should be added to the database
5. Verify by going back to the "All Users" page

### What Each Test Validates

| Test | Services Validated | Expected Result |
|------|-------------------|-----------------|
| Login | Tomcat → MariaDB | Successful authentication |
| All Users Page | Tomcat → MariaDB | Display list of users from database |
| RabbitMQ Test | Tomcat → RabbitMQ | Connection confirmation with queue stats |
| User Registration | Tomcat → MariaDB | New user created and visible in users list |
| Page Load | Nginx → Tomcat → Memcached | Fast page loads with caching |

### Troubleshooting Test Issues

**Cannot access https://192.168.56.11/**
- Ensure web01 VM is running: `vagrant status web01`
- Check Nginx is running: `vagrant ssh web01 -c "sudo systemctl status nginx"`
- Verify the IP is correct: `vagrant ssh web01 -c "ip addr show"`

**Login fails with admin_vp credentials**
- Verify MariaDB is running: `vagrant ssh db01 -c "sudo systemctl status mariadb"`
- Check database was initialized: `vagrant ssh db01 -c "sudo mysql -u root -padmin123 -e 'SHOW DATABASES;'"`
- Re-provision app01 if needed: `vagrant reload app01 --provision`

**Users list is empty**
- Database may not be populated. SSH into db01 and check:
  ```bash
  vagrant ssh db01
  sudo mysql -u root -padmin123 accounts -e "SELECT * FROM user;"
  ```
- If empty, re-provision: `vagrant destroy db01 -f && vagrant up db01`

**RabbitMQ test fails**
- Check RabbitMQ service: `vagrant ssh rmq01 -c "sudo systemctl status rabbitmq-server"`
- Verify port 5672 is open: `vagrant ssh rmq01 -c "sudo netstat -tulpn | grep 5672"`
- Check RabbitMQ users: `vagrant ssh rmq01 -c "sudo rabbitmqctl list_users"`

## Contributing
Feel free to submit issues, fork the repository, and create pull requests for any improvements.

---

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review VM logs
3. Ensure all prerequisites are met
4. Verify network connectivity between VMs
