#!/bin/sh

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start &
N8N_PID=$!

sleep 8

echo "[AWAS] Activating workflow..."
n8n update:workflow --active=true --all 2>&1

echo "[AWAS] Ready!"
wait $N8N_PID
