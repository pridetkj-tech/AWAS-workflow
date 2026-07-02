FROM n8nio/n8n:latest

USER root

# Copy workflow
COPY ./awas-workflow.json /home/node/awas-workflow.json
RUN chown node:node /home/node/awas-workflow.json

USER node

EXPOSE 5678

# Import workflow on start, then run n8n
CMD n8n import:workflow --input=/home/node/awas-workflow.json 2>/dev/null; n8n start
