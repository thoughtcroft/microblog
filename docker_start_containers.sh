#!/usr/bin/env bash

# fire up the docker containers

set -e

source .env
MYSQL_VOL=microblog-mysql-data
REDIS_VOL=microblog-redis-data
ES_VOL=microblog-elasticsearch-data

for vol in ${MYSQL_VOL} ${REDIS_VOL} ${ES_VOL}; do
  if ! docker volume inspect $vol > /dev/null 2>&1; then
    docker volume create $vol
  fi
done

docker run --name mysql -d --rm \
    -v ${MYSQL_VOL}:/var/lib/mysql \
    -e MYSQL_RANDOM_ROOT_PASSWORD=yes \
    -e MYSQL_DATABASE=microblog \
    -e MYSQL_USER=microblog \
    -e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
    mysql/mysql-server:5.7

docker run --name elasticsearch -d -p 9200:9200 -p 9300:9300 --rm \
    -v ${ES_VOL}:/usr/share/elasticsearch/data \
    -e "discovery.type=single-node" \
    docker.elastic.co/elasticsearch/elasticsearch-oss:6.1.1

docker run --name redis -d -p 6379:6379 --rm \
    -v ${REDIS_VOL}:/data \
    redis:3-alpine redis-server --appendonly yes

docker run --name microblog -d -p 8000:5000 --rm -e SECRET_KEY=${SECRET_KEY} \
    -e MAIL_SERVER=${MAIL_SERVER} -e MAIL_PORT=${MAIL_PORT} -e MAIL_USE_TLS=${MAIL_USE_TLS} \
    -e MAIL_USERNAME=${MAIL_USERNAME} -e MAIL_PASSWORD=${MAIL_PASSWORD} \
    --link mysql:dbserver \
    -e DATABASE_URL=mysql+pymysql://microblog:${MYSQL_PASSWORD}@dbserver/microblog \
    --link elasticsearch:elasticsearch \
    -e ELASTICSEARCH_URL=http://elasticsearch:9200 \
    --link redis:redis-server \
    -e REDIS_URL=redis://redis-server:6379/0 \
    microblog:latest

docker run --name rq-worker -d --rm -e SECRET_KEY=${SECRET_KEY} \
    -e MAIL_SERVER=${MAIL_SERVER} -e MAIL_PORT=${MAIL_PORT} -e MAIL_USE_TLS=${MAIL_USE_TLS} \
    -e MAIL_USERNAME=${MAIL_USERNAME} -e MAIL_PASSWORD=${MAIL_PASSWORD} \
    --link mysql:dbserver \
    -e DATABASE_URL=mysql+pymysql://microblog:${MYSQL_PASSWORD}@dbserver/microblog \
    --link redis:redis-server \
    -e REDIS_URL=redis://redis-server:6379/0 \
    --entrypoint venv/bin/rq \
    microblog:latest worker -u redis://redis-server:6379/0 microblog-tasks
