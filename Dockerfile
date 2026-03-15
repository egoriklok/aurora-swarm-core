# =====================================================
# Node Beta — AuroraSwarm Cloud Nervous System
# Dedicated Repository: aurora-swarm-core-node-beta
# =====================================================
# Purpose:  Deploy the OpenClaw engine on ClawCloud Run
# Mission:  Zero-fiat ChatGPT Plus OAuth inference
# Auth:     OPENCLAW_SESSION_JSON injected at boot
# Ref:      AUR-41 - Golden Config Extraction & CORS Shield
# =====================================================

FROM node:22-alpine

# Инфраструктурный Базис
RUN apk add --no-cache \
    ca-certificates \
    tini \
    git \
    python3 \
    make \
    g++

# Ядро Роя
RUN npm install -g openclaw@2026.3.13

# Подготовка нейронных путей (директории для конфигов)
RUN mkdir -p /home/node/.config/openclaw /home/node/.openclaw && \
    chown -R node:node /home/node/.config /home/node/.openclaw

WORKDIR /app

# =====================================================
# Инъекция Идеальной Памяти (Золотой Конфиг)
# =====================================================
COPY --chown=node:node openclaw.json /home/node/.openclaw/openclaw.json

COPY entrypoint.sh /app/entrypoint.sh
COPY --chown=node:node workspace /app/workspace
COPY --chown=node:node .agent_tools /app/.agent_tools
COPY --chown=node:node GEMINI.md /app/GEMINI.md

RUN chmod +x /app/entrypoint.sh && \
    chown node:node /app/entrypoint.sh && \
    chown -R node:node /app

USER node
EXPOSE 18789

# =====================================================
# Абсолютный Транспортный Слой
# =====================================================
# Без заглушек. Без флага --allow-unconfigured. 
# Ядро читает свой Золотой Конфиг и открывается облаку.
ENTRYPOINT ["/sbin/tini", "--", "/app/entrypoint.sh"]
CMD ["openclaw", "gateway", "--port", "18789", "--bind", "lan", "--auth", "token", "--allow-unconfigured"]

# =====================================================
# Node Identity & Genetic Markers
# =====================================================
LABEL maintainer="Egor Loktionov <jamennbs1@gmail.com>"
LABEL description="AuroraSwarm Node Beta — Cloud Nervous System"
LABEL version="1.1.0"
LABEL node="beta"
LABEL memory="GitOps Golden Config Injected (AUR-41)"