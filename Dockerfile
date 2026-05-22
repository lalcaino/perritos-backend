
FROM node:18-alpine AS builder

WORKDIR /app


COPY package*.json ./


RUN npm ci --only=production && \
    npm cache clean --force


FROM node:18-alpine AS production


RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app


COPY --from=builder /app/node_modules ./node_modules


COPY --chown=appuser:appgroup . .


USER appuser


EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:3001/api/health || exit 1

CMD ["node", "server.js"]