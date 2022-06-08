#!/bin/bash

if [[ $1 == "db" ]]; then
  docker build -t hardening-db src/hardening/db/
  docker run -d -p 5432:5432 hardening-db
  docker run -d -p 6379:6379 redis

fi

if [[ $1 == "app" ]]; then
  cd src/app
  npm run dev

fi

if [[ $1 == "api" ]]; then
  export DB_HOST=localhost
  export DB_USER=postgres
  export DB_PASSWORD=password
  export DB_NAME=hardening
  export JWT_SECRET=secret
  export REDIS_HOSTNAME=localhost

  cd src/hardening
  go run main.go

fi

if [[ $1 == "" ]]; then
  cd src/hardening
  go run main.go &

  cd ../../app
  npm run dev &

  wait

fi
