FROM n8nio/n8n:latest

USER root

# Copy workflow, credential & startup script
COPY ./awas-workflow.json /home/node/awas-workflow.json
COPY ./telegram-credential.json /home/node/telegram-credential.json
COPY ./start.sh /start.sh
RUN chmod +x /start.sh && chown node:node /home/node/awas-workflow.json /home/node/telegram-credential.json /start.sh

EXPOSE 5678

ENTRYPOINT ["/start.sh"]
