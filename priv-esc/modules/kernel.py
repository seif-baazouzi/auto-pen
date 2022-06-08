import json

with open("data/linux-kernel-data.json") as f:
  versions = json.loads(f.read())

def kernelResults(version):
  if version in versions:
    cves = ",".join(versions[version])
    return {
      "title": "Linux kernel",
      "results": [{
        "message": f"The kernel version {version} has this cves {cves}",
        "scripts": []
      }]
    }
  
  return {
    "title": "Linux kernel",
    "log": False,
    "results": [{
      "message": f"The kernel version {version} has no cve",
      "scripts": []
    }]
  }
