#!/bin/sh

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start &
N8N_PID=$!

sleep 6

echo "[AWAS] Activating via API..."
node -e "
const http = require('http');

function req(method, path, data, cookie) {
  return new Promise((resolve) => {
    const opts = {
      hostname: 'localhost', port: 5678,
      path, method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (data) opts.headers['Content-Length'] = Buffer.byteLength(data);
    if (cookie) opts.headers['Cookie'] = cookie;
    const r = http.request(opts, (res) => {
      let body = '';
      res.on('data', c => body += c);
      res.on('end', () => resolve({ status: res.statusCode, body, cookie: res.headers['set-cookie'] }));
    });
    r.on('error', (e) => resolve({ status: 0, body: e.message }));
    if (data) r.write(data);
    r.end();
  });
}

async function main() {
  // Setup owner
  let r = await req('POST', '/rest/owner/setup', JSON.stringify({
    email: 'admin@awas.com', firstName: 'Admin', lastName: 'AWAS', password: 'Admin123!'
  }));
  console.log('Setup:', r.status);

  let cookie = r.cookie ? r.cookie.map(c => c.split(';')[0]).join('; ') : '';
  if (!cookie) {
    // Try login if already set up
    r = await req('POST', '/rest/login', JSON.stringify({
      email: 'admin@awas.com', password: 'Admin123!'
    }));
    console.log('Login:', r.status);
    if (r.cookie) cookie = r.cookie.map(c => c.split(';')[0]).join('; ');
  }

  // Create credential
  r = await req('POST', '/rest/credentials', JSON.stringify({
    name: 'Telegram', type: 'telegramApi', data: { accessToken: '8968531618:AAGdkTRhS9PbsgUZrRSwP5GxvfXckfXMvXU' }
  }), cookie);
  console.log('Cred:', r.status);

  // List & activate workflow
  r = await req('GET', '/rest/workflows', null, cookie);
  try {
    const wfs = JSON.parse(r.body);
    const wf = wfs.data?.[0] || wfs[0];
    if (wf?.id) {
      r = await req('PATCH', '/rest/workflows/' + wf.id, JSON.stringify({ active: true }), cookie);
      console.log('Activate:', r.status, wf.id);
    }
  } catch(e) { console.log('Error:', e.message); }

  console.log('[AWAS] Done!');
}

main();
"

echo "[AWAS] Ready!"
wait $N8N_PID
