#!/usr/bin/env python

import os 
from flask import Flask, render_template_string, request

app = Flask(__name__)

@app.get("/")
def index():
  return render_template_string(f"""
    <h1>Home</h1>
    <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Harum voluptatum dicta tempora deserunt. Accusantium, necessitatibus, iste vero ducimus sint atque dolorem neque, earum ipsa ipsum vitae aliquid aut exercitationem unde!</p>
    <a href="hi/seif">Say hi</a>
    <a href="/ping">Ping</a>
  """)

@app.get("/hi/<name>")
def hi(name):
  return render_template_string(f"""
    <h1>Hi {name}</h1>
    <p>Lorem ipsum dolor sit amet consectetur adipisicing elit.</p>
    <a href="/">Home</a>
  """)

@app.route("/ping", methods=[ "GET", "POST" ])
def ping():
  if request.method == 'POST':
    host = request.form['host']
    ping = os.popen(f"ping -c 1 {host}").read()
  else:
    host = ""
    ping = ""

  return f"""
    <h1>Ping As A Service</h1>
    <form method="POST">
      <label>Host: </label>
      <input type="text" name="host" value="{host}">
      <button>ping</button>
    </form>
    <pre>
      <code>{ping}</code>
    </pre>
    <a href="/">Home</a>
  """
  
@app.errorhandler(404)
def page_not_found(e):
  return f"""
    <h1>404 Not Found</h1>
    <p>path {request.path} not found</p> 
  """, 404

if __name__ == "__main__":
  app.run(debug=True, port=8080, host="0.0.0.0")
