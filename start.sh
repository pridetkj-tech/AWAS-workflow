#!/bin/sh

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start &
N8N_PID=$!

# Wait for n8n API
echo "[AWAS] Waiting for n8n API..."
for i in $(seq 1 30); do
  sleep 2
  if curl -s --max-time 2 http://localhost:5678/ > /dev/null 2>&1; then
    echo "[AWAS] n8n API ready!"
    break
  fi
  echo "  ...waiting ($i)"
done

# Create credential with same ID as in workflow
echo "[AWAS] Creating Telegram credential..."
curl -s -X POST http://localhost:5678/rest/credentials \
  -H "Content-Type: application/json" \
  -H "X-N8N-API-KEY: awas-secret-key-123" \
  -d '{
    "id": "T5twnBCiF8KWTqfJ",
    "name": "Telegram account",
    "type": "telegramApi",
    "data": {
      "accessToken": "8968531618:AAGdkTRhS9PbsgUZrRSwP5GxvfXckfXMvXU"
    }
  }' 2>&1

echo ""

# Find & activate workflow via API
echo "[AWAS] Activating workflow..."
WF_LIST=$(curl -s http://localhost:5678/rest/workflows \
  -H "X-N8N-API-KEY: awas-secret-key-123")
WF_ID=$(echo "$WF_LIST" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$WF_ID" ]; then
  echo "[AWAS] Activating workflow ID: $WF_ID"
  curl -s -X PATCH "http://localhost:5678/rest/workflows/$WF_ID" \
    -H "Content-Type: application/json" \
    -H "X-N8N-API-KEY: awas-secret-key-123" \
    -d '{"active": true}' 2>&1
else
  echo "[AWAS] Workflow not found by API"
fi

echo ""
echo "[AWAS] Ready!"
wait $N8N_PID
