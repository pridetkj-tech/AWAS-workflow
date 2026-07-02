#!/bin/sh

echo "[AWAS] Importing Telegram credential..."
n8n import:credential --input=/home/node/telegram-credential.json 2>&1

echo "[AWAS] Importing & activating workflow..."
n8n import:workflow --active --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start
