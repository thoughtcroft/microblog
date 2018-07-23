#!/usr/bin/env bash

# create the user

USER=$1
FILE=$2

if ! id -u $USER  > /dev/null 2>&1; then
  adduser --quiet --disabled-password --shell /bin/bash --home /home/$USER --gecos "" $USER
  usermod -aG sudo $USER
fi

cd /home/$USER

mkdir -p .ssh
cat $FILE >> .ssh/authorized_keys
chown $USER:$USER -R .ssh
chmod 600 .ssh/authorized_keys
