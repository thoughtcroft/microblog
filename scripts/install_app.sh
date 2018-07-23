#!/usr/bin/env bash

# install the app

USER=$1

source /tmp/.env
cd /home/${USER}
if [ ! -d "microblog" ]; then
  git clone ${APP_REPOSITORY} microblog --quiet
fi
cd microblog

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
pip install gunicorn pymysql

if [ -f ".env" ]; then
  rm -f .env
fi
touch .env
echo SECRET_KEY=$(python3 -c "import uuid; print(uuid.uuid4().hex)") >> .env
echo MAIL_SERVER=localhost >> .env
echo MAIL_PORT=25 >> .env
echo MYSQL_USER_PASSWORD=${MYSQL_USER_PASSWORD} >> .env
echo DATABASE_URL=mysql+pymysql://microblog:${MYSQL_USER_PASSWORD}@localhost:3306/microblog >> .env
echo MS_TRANSLATOR_KEY=${MS_TRANSLATOR_KEY} >> .env

flask translate compile
flask db upgrade
