# =====================================================
# Node Beta — AuroraSwarm Cloud Nervous System
# Dedicated Repository: aurora-swarm-core-node-beta
# =====================================================
# Purpose:  Deploy the OpenClaw engine on ClawCloud Run
# Mission:  Zero-fiat ChatGPT Plus OAuth inference, no PC dependency
# Auth:     OPENCLAW_SESSION_JSON injected at boot via entrypoint.sh
# Ref:      AUR-39 - Absolute Synthesis: Swarm Identity & Network Sovereignty
# =====================================================

FROM node:22-alpine

# [1] Инфраструктурный Базис (Runtime Dependencies)
RUN apk add --no-cache \
    ca-certificates \
    tini \
    git \
    python3 \
    make \
    g++

# [2] Ядро Роя (Engine Installation)
# Pinned for reproducible builds — sentinel bumps via AUR workflow
RUN npm install -g openclaw@2026.3.13

# Create config directory for session hydration and grant ownership to node user
RUN mkdir -p /home/node/.config/openclaw && chown -R node:node /home/node/.config

WORKDIR /app

# =====================================================
# Session Hydration & Cellular Memory (AUR-9 & AUR-30)
# =====================================================
COPY entrypoint.sh /app/entrypoint.sh

# Инъекция Генетической Памяти и Щита в кристалл
COPY --chown=node:node workspace /app/workspace
COPY --chown=node:node .agent_tools /app/.agent_tools
COPY --chown=node:node GEMINI.md /app/GEMINI.md

RUN chmod +x /app/entrypoint.sh && \
    chown node:node /app/entrypoint.sh && \
    chown -R node:node /app

USER node
EXPOSE 18789

# =====================================================
# The Sovereign Transport Layer
# =====================================================
# tini → entrypoint.sh (hydration) → openclaw (guardrail override: bind lan + auth none)
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["openclaw", "gateway", "--port", "18789", "--bind", "lan", "--auth", "none", "--allow-unconfigured"]

# =====================================================
# Node Identity & Genetic Markers
# =====================================================
LABEL maintainer="Egor Loktionov <jamennbs1@gmail.com>"
LABEL description="AuroraSwarm Node Beta — Cloud Nervous System (openclaw engine)"
LABEL version="1.1.0"
LABEL node="beta"
LABEL auth="ChatGPT Plus OAuth via OPENCLAW_SESSION_JSON headless injection (AUR-9)"
LABEL memory="GitOps Cellular Workspace Mounted (AUR-30)"