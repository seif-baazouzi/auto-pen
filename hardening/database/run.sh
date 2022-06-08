#!/bin/bash

cat tables.sql technologies.sql > db.sql
docker build -t hardening-db .
