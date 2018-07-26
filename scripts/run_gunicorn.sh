#!/usr/bin/env bash

# set up web workers

SUPER_PATH=/etc/supervisor/conf.d
SUPER_FILE=microblog.conf
SUPER_CONTENT=$(cat <<EOF_SUPERVISOR
[program:microblog]
command=/home/ubuntu/microblog/venv/bin/gunicorn -b localhost:8000 -w 4 microblog:app
directory=/home/ubuntu/microblog
user=ubuntu
stdout_logfile=/var/log/microblog/gunicorn.log
redirect_stderr=true
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
EOF_SUPERVISOR
)

mkdir -p ${SUPER_PATH}
cd ${SUPER_PATH}
if [ -f ${SUPER_FILE} ]; then
  rm -f ${SUPER_FILE}
fi

echo "${SUPER_CONTENT}" > ${SUPER_FILE}
mkdir -p /var/log/microblog

supervisorctl reload || supervisorctl start all
