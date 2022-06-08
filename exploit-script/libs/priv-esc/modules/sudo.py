import json

with open("data/sudo-data.json") as f:
  versions = json.loads(f.read())

def sudoResults(version):
  if version in versions:
    cves = ",".join(versions[version])
    return {
      "title": "Sudo",
      "results": [{
        "message": f"The sudo version {version} has this cves {cves}",
        "scripts": []
      }]
    }
  
  return {
    "title": "Sudo",
    "log": False,
    "results": [{
      "message": f"The sudo version {version} has no cve",
      "scripts": []
    }]
  }
