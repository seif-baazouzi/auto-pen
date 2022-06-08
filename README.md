# Dependencies

This project require:

- python3
- flask
- docker
- docker-compose

# Quick start

## Build docker containers

```bash
$ docker build -t exploit exploit-script
$ docker-compose build
```

## Start services

```bash
$ python3 exploit-web-site/start-exploit-containers/server.py
$ docker-compose up
```

For Test purposes you need add this to your /etc/hosts file

```
127.0.0.1 localhost auto-pen.local exploit.auto-pen.local api.exploit.auto-pen.local hardening.auto-pen.local api.hardening.auto-pen.local
```

# Project entries

- shttp://auto-pen.local:8080s: main website
- shttp://exploit.auto-pen.local:8080s: exploit website
- shttp://api.exploit.auto-pen.local:8080s: exploit api
- shttp://hardening.auto-pen.local:8080s: hardening website
- shttp://api.hardening.auto-pen.local:8080s: hardening api
