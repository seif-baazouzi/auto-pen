import os
import argparse
from flask import Flask

from utils import *
from modules import *

app = Flask(__name__)

parser = argparse.ArgumentParser()
parser.add_argument("--log", help="Log file")
args = parser.parse_args()

@app.get("/get-client")
def getClient():
  with open("client.sh", "r") as f:
    return f.read()

@app.get("/suids/<binaries>")
def suids(binaries):
  results = suidsResults(bs64Decode(binaries))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/sudoers/<message>")
def sudoers(message):
  results = sudoersResults(bs64Decode(message))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/passwd/<message>")
def passwd(message):
  results = passwdResults(bs64Decode(message))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/shadow/<message>")
def shadow(message):
  results = shadowResults(bs64Decode(message))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/sudo/<version>")
def sudo(version):
  results = sudoResults(bs64Decode(version))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/kernel/<version>")
def kernel(version):
  results = kernelResults(bs64Decode(version))
  if args.log:
    logResults(args.log, results)
  
  return formatResults(results)

@app.get("/close")
def close():
  os.kill(os.getpid(), 9)  
  return "ok"
