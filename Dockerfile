FROM n8nio/n8n:latest

# Copy workflow
COPY ./awas-workflow.json /home/node/.n8n/workflows/

# Expose port
EXPOSE 5678

# Start n8n
CMD ["n8n", "start"]
