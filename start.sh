#!/bin/sh

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start &
N8N_PID=$!

sleep 6

echo "[AWAS] Getting workflow ID..."
WF_JSON=$(n8n export:workflow --all 2>/dev/null)
WF_ID=$(echo "$WF_JSON" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{try{console.log(JSON.parse(d)[0]?.id||'')}catch(e){console.log('')}})")
echo "[AWAS] Workflow ID: $WF_ID"

if [ -n "$WF_ID" ]; then
  echo "[AWAS] Activating workflow..."
  n8n publish:workflow --id="$WF_ID" 2>&1
  n8n update:workflow --active=true --id="$WF_ID" 2>&1 || true
else
  echo "[AWAS] Could not find workflow ID"
fi

echo "[AWAS] Ready!"
wait $N8N_PID
