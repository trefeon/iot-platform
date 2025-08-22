"""Simple IoT Platform"""
import json
from flask import Flask, jsonify

app = Flask(__name__)

# Store sensor data
data = {"temperature": 0, "humidity": 0, "light": 0}

@app.route('/')
def home():
    with open('static/index.html') as f:
        return f.read()

@app.route('/api/data')
def api():
    return jsonify(data)

if __name__ == '__main__':
    print("Starting IoT Platform on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000)
