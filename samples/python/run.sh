#!/bin/bash

if [[ "$1" == "" ]]; then
  ./server.py

fi

if [[ "$1" == "build" ]]; then
  docker build -t flask_vuln .
  
fi

if [[ "$1" == "run" ]]; then
  docker run -d -p 8080:8080 flask_vuln
  
fi
