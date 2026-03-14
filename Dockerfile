# =====================================================
# Node Beta — AuroraSwarm Cloud Nervous System
# Dedicated Repository: aurora-swarm-core-node-beta
# =====================================================
# Purpose:  Deploy the OpenClaw engine on ClawCloud Run
# Mission:  Zero-fiat ChatGPT Plus OAuth inference, no PC dependency
# Auth:     OPENCLAW_SESSION_JSON injected at boot via entrypoint.sh
# Ref:      AUR-28 - Hotfix: Streamlined single-stage build (npm ci removed)
# =====================================================

FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tini \
    git \
    python3 \
    make \
    g++

# Install openclaw engine globally (pinned for reproducible builds — sentinel bumps via AUR workflow)
RUN npm install -g openclaw@2026.3.13

# Create config directory for session hydration
RUN mkdir -p /home/node/.config/openclaw

WORKDIR /app

# =====================================================
# Session Hydration & Cellular Memory (AUR-9 & AUR-30)
# =====================================================
COPY entrypoint.sh /app/entrypoint.sh

# Инъекция Генетической Памяти и Щита в кристалл
COPY --chown=node:node workspace /app/workspace
COPY --chown=node:node .agent_tools /app/.agent_tools
COPY --chown=node:node GEMINI.md /app/GEMINI.md
COPY --chown=node:node CLAUDE.md /app/CLAUDE.md

RUN chmod +x /app/entrypoint.sh && \
    chown node:node /app/entrypoint.sh && \
    chown -R node:node /app

USER node

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:8080/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); });"

EXPOSE 8080

# tini → entrypoint.sh (session hydration) → openclaw (с привязкой к памяти)
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["openclaw", "start", "--port", "8080", "--workspace", "/app/workspace"]

LABEL maintainer="Egor Loktionov <jamennbs1@gmail.com>"
LABEL description="AuroraSwarm Node Beta — Cloud Nervous System (openclaw engine)"
LABEL version="1.1.0"
LABEL node="beta"
LABEL auth="ChatGPT Plus OAuth via OPENCLAW_SESSION_JSON headless injection (AUR-9)"
LABEL memory="GitOps Cellular Workspace Mounted (AUR-30)"