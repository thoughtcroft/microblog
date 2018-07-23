#!/usr/bin/env bash

# this hack overcomes mysql-5.6 issue on Ubuntu

HACK_FILE=/etc/tmpfiles.d/mysql.conf
HACK_TEXT=$(cat <<HACK
# systemd tmpfile settings for mysql
# see tmpfiles.d(5) for details
d /var/run mysqld 0755 mysql mysql -
HACK
)

if [ -f "${HACK_FILE}" ]; then
  rm -f ${HACK_FILE}
fi
echo "${HACK_TEXT}" > ${HACK_FILE}

# create random passwords

if ! grep -q MYSQL_ROOT_PASSWORD /tmp/.env 2>/dev/null; then
  echo "export MYSQL_ROOT_PASSWORD=$(openssl rand -base64 12)" >> /tmp/.env
  echo "export MYSQL_USER_PASSWORD=$(openssl rand -base64 12)" >> /tmp/.env
fi

source /tmp/.env

# install the database

debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
apt-get -y install mysql-server

# create the database

CREATE_DB_SCRIPT=$(cat <<SQL
  CREATE DATABASE IF NOT EXISTS microblog CHARACTER SET utf8 COLLATE utf8_bin;
  CREATE USER IF NOT EXISTS 'microblog'@'localhost' identified by '${MYSQL_USER_PASSWORD}';
  GRANT ALL PRIVILEGES ON microblog.* TO 'microblog'@'localhost';
  FLUSH PRIVILEGES;
SQL
)

MYSQL_PWD=${MYSQL_ROOT_PASSWORD} mysql --user=root --execute="${CREATE_DB_SCRIPT}"
