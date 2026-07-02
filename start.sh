#!/bin/sh

echo "[AWAS] Starting n8n..."
n8n start &
N8N_PID=$!

sleep 5

echo "[AWAS] Importing & activating workflow..."
n8n import:workflow --active --input=/home/node/awas-workflow.json 2>&1 && \
echo "[AWAS] Workflow activated!" || \
echo "[AWAS] Import done"

echo "[AWAS] Ready!"
wait $N8N_PID
