#!/usr/bin/env bash

# build the docker containers

set -e

source .env

docker build -t microblog:latest .
