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
    reqs = requests.get(f"{url}/version-list/15714/32625/1/Sudo-Project-Sudo.html?order=0")
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

def scrapeData(path, data):
  try:
    reqs = requests.get(f"{url}{path}")
    soup = BeautifulSoup(reqs.text, "html.parser")
  except:
    print("[-] Failed")
    exit(1)

  for row in soup.select(".listtable tr")[1:]:
    version = row.select("td:first-child")[0].text.strip()
    if version in data or version == "*":
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

  with open("data/sudo-data.json", "w+") as f:
    f.write(json.dumps(data))

#######################################################################################
#######################################################################################
#######################################################################################

if __name__ == "__main__":
  main()
