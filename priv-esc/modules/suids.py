import re
import json

with open("data/gtfobins-suids-data.json") as f:
  suids = json.loads(f.read())

#######################################################################################
#######################################################################################
#######################################################################################

def getGtfobin(binary):
  binaryName = binary.split("/")[-1]
  if binaryName not in suids:
    return None

  scripts = []
  print(binaryName, type(suids[binaryName]))
  for s in suids[binaryName]:
    s = re.sub(r"(\./" + re.escape(binaryName) +")|(" + re.escape(binaryName) + ")", binary, s)
    scripts.append(s)

  return scripts

#######################################################################################
#######################################################################################
#######################################################################################

def suidsResults(binaries):
  results = {
    "title": "Suids binaries",
    "results": []
  }

  for binary in binaries.split(","):
    binary = binary.strip()
    if not binary:
      continue
    
    scripts = getGtfobin(binary)
    if scripts != None and len(scripts):
      results["results"].append({
        "message": f"Binary {binary}",
        "scripts": scripts
      })

  if len(results["results"]) == 0:
    results["results"].append({ "message": "The is not GTFOBINS SUIDS binaries", "scripts": [] })
    
  return results
