#!/usr/bin/env bash

# set up background workers

SUPER_PATH=/etc/supervisor/conf.d
SUPER_FILE=rq_microblog.conf
SUPER_CONTENT=$(cat <<EOF_SUPERVISOR
[program:microblog_bg]
command=/home/ubuntu/microblog/venv/bin/rq worker microblog-tasks
directory=/home/ubuntu/microblog
process_name=%(program_name)-%(process_num)s
numprocs=2
user=ubuntu
stdout_logfile=/var/log/microblog/bg_worker.log
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
