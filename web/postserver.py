from flask import Flask, request, jsonify
import json

app = Flask(__name__)

@app.route('/coins', methods=['POST'])
def coins():
    data = request.get_json()
    print(f"Received data: {data}")
    # Append the JSON data to coin_post.json with newline separation
    with open("coin_post.json", "a") as f:
        f.write(json.dumps(data) + "\n")
    return jsonify({"status": "ok"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
