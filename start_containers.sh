#!/usr/bin/env bash

# fire up the docker containers

source .env

docker run --name elasticsearch -d -p 9200:9200 -p 9300:9300 --rm \
    -e "discovery.type=single-node" \
    docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1

docker run --name mysql -d -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
    -e MYSQL_DATABASE=microblog -e MYSQL_USER=microblog \
    -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    mysql/mysql-server:5.7

docker run --name microblog -d -p 8000:5000 --rm -e SECRET_KEY=${SECRET_KEY} \
    -e MAIL_SERVER=${MAIL_SERVER} -e MAIL_PORT=${MAIL_PORT} -e MAIL_USE_TLS=${MAIL_USE_TLS} \
    -e MAIL_USERNAME=${MAIL_PASSWORD} -e MAIL_PASSWORD=${MAIL_PASSWORD} \
    --link mysql:dbserver \
    -e DATABASE_URL=mysql+pymysql://microblog:${MYSQL_PASSWORD}@dbserver/microblog \
    --link elasticsearch:elasticsearch \
    -e ELASTICSEARCH_URL=http://elasticsearch:9200 \
    microblog:latest
