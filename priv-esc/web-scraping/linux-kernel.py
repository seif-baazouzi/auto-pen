import re
import json
import requests
from bs4 import BeautifulSoup

#######################################################################################
#######################################################################################
#######################################################################################

url = "https://www.cvedetails.com"

#######################################################################################
#######################################################################################
#######################################################################################

def getCves(path):
  try:
    reqs = requests.get(f"{url}{path}")
    soup = BeautifulSoup(reqs.text, "html.parser")
  except:
    print("[-] Failed")
    exit(1)
  
  cves = []
  for row in soup.select("#vulnslisttable tr")[1:-1]:
    links = row.select("a[title^=CVE]")
    if len(links):
      cve = links[0].text.strip()
      cves.append(cve)
  
  return cves

#######################################################################################
#######################################################################################
#######################################################################################

def getPages():
  try:
    reqs = requests.get(f"{url}/version-list/33/47/1/Linux-Linux-Kernel.html")
    soup = BeautifulSoup(reqs.text, "html.parser")
  except:
    print("[-] Failed")
    exit(1)

  pages = []
  for link in soup.select("#pagingb a"):
    pagePath = link.get("href")
    pages.append(pagePath)
  
  return pages

#######################################################################################
#######################################################################################
#######################################################################################

def isValidVersion(version):
  if re.match("^[0-9]+\.[0-9]+\.[0-9]+$", version) or re.match("^[0-9]+\.[0-9]+$", version):
    return True
  
  return False

#######################################################################################
#######################################################################################
#######################################################################################

def scrapeData(path, data):
  try:
    reqs = requests.get(f"{url}{path}")
    soup = BeautifulSoup(reqs.text, "html.parser")
  except:
    print("[-] Failed")
    exit(1)

  for row in soup.select(".listtable tr")[1:]:
    version = row.select("td:first-child")[0].text.strip()
    if version in data or version == "*" or not isValidVersion(version):
      continue
    
    links = row.select("a[title^=Vulnerabilities]")
    if len(links):
      cvePagePath = links[0].get("href")
      cves = getCves(cvePagePath)

    if len(cves):
      data[version] = cves
      print(version, cves)

#######################################################################################
#######################################################################################
#######################################################################################

def main():
  data = {}
  
  pages = getPages()
  for page in pages:
    scrapeData(page, data)

  with open("data/linux-kernel-data.json", "w+") as f:
    f.write(json.dumps(data))

#######################################################################################
#######################################################################################
#######################################################################################

if __name__ == "__main__":
  main()
