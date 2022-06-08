import json
import base64

def bs64Decode(data):
  return str(base64.b64decode(data), "utf-8")

def logResults(file, data):
  if "log" in data and data["log"] == False:
    return
  
  if data:
    with open(file, "a") as f:
      f.write(json.dumps(data) + "\n")

def formatResults(data):
  output = []
  for res in data["results"]:
    if res["message"]:
      output.append(res["message"])
      output.append("")
    
    for script in res["scripts"]:
      s = "\n".join([ "$ " + line for line in script.split("\n") if line ])
      output.append(s)
      output.append("")

  return "\n".join(output)
