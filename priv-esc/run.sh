#!/bin/bash

if [[ "$1" == "start-server" ]]; then
  python -B server.py
fi

if [[ "$1" == "update-data" ]]; then
  python -B web-scraping/sudo.py
  python -B web-scraping/linux-kernel.py
  python -B web-scraping/gtfobins-suids.py

fi

if [[ "$1" == "" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
  echo "Usage: $0 [OPTION]"
  echo
  echo "Options:"
  echo "  start-server     start the server"
  echo "  update-data      scrape the new data"
  echo "  -h,--help        show this help"
  echo

fi
