#!/usr/bin/env bash

# set up nginx
CERTS_PATH=/home/ubuntu/microblog/certs
DEFAULT_SITE=/etc/nginx/sites-enabled/default
NGINX_FILE=/etc/nginx/sites-enabled/microblog
NGINX_CONTENT=$(cat <<'EOF_NGINX'
server {
    # listen on port 80 (http)
    listen 80;
    server_name _;
    location / {
        # redirect any requests to the same URL but on https
        return 301 https://$host$request_uri;
    }
}
server {
    # listen on port 443 (https)
    listen 443 ssl;
    server_name _;

    # location of the self-signed SSL certificate
    ssl_certificate /home/ubuntu/microblog/certs/cert.pem;
    ssl_certificate_key /home/ubuntu/microblog/certs/key.pem;

    # write access and error logs to /var/log
    access_log /var/log/microblog/nginx_access.log;
    error_log /var/log/microblog/nginx_error.log;

    location / {
        # forward application requests to the gunicorn server
        proxy_pass http://localhost:8000;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /static {
        # handle static files directly, without forwarding to the application
        alias /home/ubuntu/microblog/app/static;
        expires 30d;
    }
}
EOF_NGINX
)


mkdir -p ${CERTS_PATH}
cd ${CERTS_PATH}
if [ ! -f "key.pem" ]; then
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
  -keyout key.pem -out cert.pem -batch
fi

if [ -f "${DEFAULT_SITE}" ]; then
  rm -f "${DEFAULT_SITE}"
fi

if [ -f "${NGINX_FILE}" ]; then
  rm -f ${NGINX_FILE}
fi
echo "${NGINX_CONTENT}" > ${NGINX_FILE}

mkdir -p /var/log/microblog
service nginx reload || service nginx start
