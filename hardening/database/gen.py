#!/usr/bin/env python

import os

filesList = os.popen("cd notes && ls -1 *.md").read().split("\n")[:-1]

sql = []
for file in filesList:
  tech = file.split(".")[0]
  with open(f"notes/{file}") as f:
    hardening = f.read().replace("'", "''")
    sql.append(f"INSERT INTO technologies VALUES ('{tech}', '{hardening}');")

with open("technologies.sql", "w+") as f:
  f.write("\n".join(sql))
