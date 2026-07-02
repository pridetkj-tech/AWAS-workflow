#!/bin/sh

# ============================================
# AWAS n8n - Auto-import workflow on startup
# ============================================

echo "[AWAS] Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1

echo "[AWAS] Starting n8n..."
n8n start
