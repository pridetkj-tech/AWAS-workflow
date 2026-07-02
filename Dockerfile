FROM node:20-alpine

RUN apk add --no-cache tini \
    && npm install -g n8n \
    && mkdir -p /home/node/.n8n/workflows \
    && chown -R node:node /home/node

USER node
WORKDIR /home/node

# Copy workflow
COPY --chown=node:node ./awas-workflow.json /home/node/.n8n/workflows/

EXPOSE 5678

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["n8n", "start"]
