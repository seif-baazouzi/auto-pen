#!/bin/bash

export DOCKER_NETWORK=auto-pen_default

python -B exploit-web-site/start-exploit-containers/server.py &

docker-compose up --build
