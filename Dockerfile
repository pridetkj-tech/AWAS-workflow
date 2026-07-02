FROM n8nio/n8n:latest

USER root

# Copy workflow & startup script
COPY ./awas-workflow.json /home/node/awas-workflow.json
COPY ./start.sh /start.sh
RUN chmod +x /start.sh && chown node:node /home/node/awas-workflow.json

USER node

EXPOSE 5678

CMD ["/bin/sh", "/start.sh"]
