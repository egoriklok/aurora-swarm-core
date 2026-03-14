# =====================================================
# Node Beta — AuroraSwarm Cloud Nervous System
# Dedicated Repository: aurora-swarm-core-node-beta
# =====================================================
# Purpose:  Deploy the OpenClaw Antigravity Gateway on ClawCloud Run
# Mission:  Zero-fiat ChatGPT Plus OAuth inference, no PC dependency
# Auth:     OPENCLAW_SESSION_JSON injected at boot via entrypoint.sh
# Ref:      AUR-9 - Node Beta Upstream Sync & Headless Auth CI/CD
# =====================================================

FROM node:20-alpine AS base

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tini

WORKDIR /app
RUN chown -R node:node /app
USER node

# =====================================================
# Dependencies Stage
# =====================================================
FROM base AS deps
COPY --chown=node:node package*.json ./
RUN npm ci --only=production --ignore-scripts && \
    npm cache clean --force

# =====================================================
# Production Stage
# =====================================================
FROM base AS production

COPY --from=deps --chown=node:node /app/node_modules ./node_modules

# Install openclaw engine
RUN npm install -g openclaw@latest

# Create config directory
RUN mkdir -p /home/node/.config/openclaw

# =====================================================
# Session Hydration Entrypoint (AUR-9)
# =====================================================
USER root
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && \
    chown node:node /app/entrypoint.sh
USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); });"

EXPOSE 8080

# tini → entrypoint.sh (session hydration) → openclaw
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["openclaw", "start", "--port", "8080"]

LABEL maintainer="Egor Loktionov <jamennbs1@gmail.com>"
LABEL description="AuroraSwarm Node Beta — Cloud Nervous System (openclaw engine)"
LABEL version="1.0.0"
LABEL node="beta"
LABEL auth="ChatGPT Plus OAuth via OPENCLAW_SESSION_JSON headless injection (AUR-9)"