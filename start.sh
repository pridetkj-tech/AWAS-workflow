#!/bin/sh

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n in background..."
n8n start &
N8N_PID=$!

# Wait for n8n using node (curl tidak tersedia)
echo "[AWAS] Waiting for n8n API..."
node -e "
const http = require('http');
function wait() {
  return new Promise((resolve) => {
    const tryConnect = (attempt) => {
      if (attempt > 30) { resolve(false); return; }
      const req = http.get('http://localhost:5678/', (res) => {
        resolve(true);
      });
      req.on('error', () => {
        setTimeout(() => tryConnect(attempt + 1), 2000);
      });
      req.end();
    };
    tryConnect(1);
  });
}
wait().then((ok) => {
  if (ok) {
    console.log('n8n API ready!');
    process.exit(0);
  } else {
    console.log('Timeout waiting for n8n');
    process.exit(1);
  }
});
"

# Create credential via n8n API (pake node sebagai ganti curl)
echo "[AWAS] Creating Telegram credential..."
node -e "
const http = require('http');
const data = JSON.stringify({
  name: 'Telegram account',
  type: 'telegramApi',
  data: { accessToken: '8968531618:AAGdkTRhS9PbsgUZrRSwP5GxvfXckfXMvXU' }
});
const req = http.request({
  hostname: 'localhost',
  port: 5678,
  path: '/rest/credentials',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data),
    'X-N8N-API-KEY': 'awas-secret-key-123'
  }
}, (res) => {
  let body = '';
  res.on('data', (chunk) => body += chunk);
  res.on('end', () => console.log('Credential:', body));
});
req.on('error', (e) => console.log('Credential error:', e.message));
req.write(data);
req.end();
"

# Activate workflow
echo "[AWAS] Activating workflow..."
node -e "
const http = require('http');
// Get workflow ID
const req = http.get({
  hostname: 'localhost',
  port: 5678,
  path: '/rest/workflows',
  headers: { 'X-N8N-API-KEY': 'awas-secret-key-123' }
}, (res) => {
  let body = '';
  res.on('data', (chunk) => body += chunk);
  res.on('end', () => {
    try {
      const wfs = JSON.parse(body);
      const wf = wfs.data?.[0] || wfs[0];
      if (wf && wf.id) {
        console.log('Workflow ID:', wf.id);
        // Activate
        const data = JSON.stringify({ active: true });
        const req2 = http.request({
          hostname: 'localhost',
          port: 5678,
          path: '/rest/workflows/' + wf.id,
          method: 'PATCH',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(data),
            'X-N8N-API-KEY': 'awas-secret-key-123'
          }
        }, (res2) => {
          let body2 = '';
          res2.on('data', (chunk) => body2 += chunk);
          res2.on('end', () => console.log('Activated:', body2));
        });
        req2.write(data);
        req2.end();
      } else {
        console.log('No workflows found:', body);
      }
    } catch(e) {
      console.log('Parse error:', e.message, body);
    }
  });
});
req.on('error', (e) => console.log('Activate error:', e.message));
req.end();
"

echo "[AWAS] Ready!"
wait $N8N_PID
