FROM node:22-bookworm

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    python3 \
    make \
    g++ \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# Cache dependency installation unless package metadata changes.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY scripts ./scripts

RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build
RUN pnpm ui:install
RUN pnpm ui:build

ENV HOME=/home/node
ENV NODE_ENV=production

# docker-setup.sh fixes bind-mount ownership for uid 1000 before onboarding.
RUN mkdir -p /home/node/.openclaw /home/node/.cache \
  && chown -R node:node /app /home/node

USER node

EXPOSE 18789 18790

CMD ["node", "dist/index.js"]
