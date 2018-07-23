#!/usr/bin/env bash

# lock down the server firewall

source /tmp/.env
apt-get -y update
apt-get install -y ufw
ufw allow ssh
ufw allow http
ufw allow 443/tcp
ufw --force enable

# restrict login access

sed -i 's/.*PermitRootLogin.*/# PermitRootLogin edited by microblog/' /etc/ssh/sshd_config
sed -i 's/.*PasswordAuthentication.*/# PasswordAuthentication edited by microlog/' /etc/ssh/sshd_config
echo -e "PermitRootLogin no\nPasswordAuthentication no" >> /etc/ssh/sshd_config
service ssh restart
