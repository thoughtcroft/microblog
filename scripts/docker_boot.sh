#!/usr/bin/env bash
cd /home/microblog
source venv/bin/activate
while true; do
    flask db upgrade 2>/dev/null
    if [ $? -eq 0 ]; then
        break
    fi
    echo Upgrade command failed, retrying in 5 secs...
    sleep 5
done
flask translate compile
exec gunicorn -b :5000 --access-logfile - --error-logfile - microblog:app
