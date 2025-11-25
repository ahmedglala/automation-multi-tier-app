#! /bin/bash
# Stop on error
set -e
# Updating system and installing nginx
echo "  |Updating system and Installing Nginx...| "
sudo apt update && sudo apt install nginx -y

# creating ssl script and generating self-signed certificate
echo "  |Generating self-signed SSL certificate...| "

cat <<'EOT' > ssl_setup.sh
# creating ssl script and generating self-signed certificate
#!/bin/bash

# This script generates a self-signed SSL certificate for local development.

# Create a directory for the SSL certs if it doesn't exist
mkdir -p ssl

# Generate the SSL certificate and key using openssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx.key \
  -out ssl/nginx.crt \
  -subj "/C=EG/ST=Cairo/L=Cairo/O=socialapp/CN=app01"

echo "✅ SSL certificate and key generated successfully in the 'ssl/' directory."

EOT
# running the ssl script
echo "  |Running SSL Setup Script && Change Permissions To Be Executable...| "
chmod +x ssl_setup.sh
./ssl_setup.sh

# creating nginx config file for the tomcat app
echo "  |Creating Nginx Configuration for the Tomcat Application...| "
cat <<'EOT' > socialapp
# Redirect plain HTTP requests to HTTPS when user types app01
server {
    listen 80;
    listen [::]:80;
    server_name app01; # server name for the tomcat app

    return 301 https://$host$request_uri; 
}

# HTTPS server for app01 (proxy to backend)
server {
    listen 443 ssl http2;  # HTTPS server for app01 (proxy to backend)
    listen [::]:443 ssl http2; # HTTPS server for app01 (proxy to backend) ipv6
    server_name app01; # server name for the tomcat app

    ssl_certificate /home/vagrant/ssl/nginx.crt; # server certificate
    ssl_certificate_key /home/vagrant/ssl/nginx.key; # server private key
    ssl_protocols TLSv1.2 TLSv1.3; # supported protocols
    ssl_ciphers HIGH:!aNULL:!MD5;# cipher suites
    ssl_prefer_server_ciphers on; # prefer server ciphers
    ssl_session_cache shared:SSL:10m; # SSL session cache
    ssl_session_timeout 10m; # SSL session timeout

    location / { # proxy to backend
        proxy_pass http://app01:8080; # backend server
        proxy_set_header Host $host; # pass the original host header
        proxy_set_header X-Real-IP $remote_addr; # pass the real client IP
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; # pass the X-Forwarded-For header
        proxy_set_header X-Forwarded-Proto $scheme; # pass the X-Forwarded-Proto header
        proxy_http_version 1.1;# use HTTP/1.1 for proxying
        proxy_set_header Connection "";  # disable connection header
        proxy_buffering off; # disable buffering
    }
}

EOT

# moving nginx config file to sites-available and enabling it
echo "  |Moving Nginx Configuration to sites-available and Enabling It...| "
sudo mv socialapp /etc/nginx/sites-available/socialapp
sudo rm -rf /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/socialapp /etc/nginx/sites-enabled/socialapp

#starting nginx service and firewall
echo "  |Starting and Enabling Nginx Service...| "
sudo systemctl start nginx
sudo systemctl enable nginx
# Restart Nginx to apply new configuration (if needed)
sudo systemctl restart nginx
