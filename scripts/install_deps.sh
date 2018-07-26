#!/usr/bin/env bash

# install base dependencies

source /home/ubuntu/.env

apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential libssl-dev libffi-dev
apt-get -y install python3 python3-venv python3-dev
apt-get -y install supervisor nginx git

debconf-set-selections <<< "postfix postfix/mailname string ${POSTFIX_MAILNAME}"
debconf-set-selections <<< "postfix postfix/main_mailer_type string '${POSTFIX_MAILER_TYPE}'"
apt-get -y install postfix
