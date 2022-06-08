#!/usr/bin/env python3

from app import app

if __name__ == "__main__":
  app.run(debug=True, port=5656, host="0.0.0.0")
