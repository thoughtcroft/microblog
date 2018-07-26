#!/usr/bin/env bash

apt-get -y remove --purge mysql-server mysql-common
rm -rf /etc/mysql /var/lib/mysql
apt-get -y autoremove
apt-get -y autoclean
apt-get -y purge mysql*
