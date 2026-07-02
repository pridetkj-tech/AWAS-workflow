#!/bin/sh

# Import workflow setiap container start (aman dipanggil berulang kali)
echo ">>> Importing workflow..."
n8n import:workflow --input=/home/node/awas-workflow.json 2>&1 || echo ">>> Import skipped or already exists"

# Start n8n
echo ">>> Starting n8n..."
n8n start
