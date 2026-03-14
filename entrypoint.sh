#!/bin/sh
# =============================================================================
# entrypoint.sh — Node Beta Session Hydration
# AUR-9: Headless Auth Injection for ClawCloud Run PaaS
#
# Decodes OPENCLAW_SESSION_JSON environment secret into disk before
# the antigravity-gateway engine initializes. This enables zero-fiat
# ChatGPT Plus OAuth-based inference without baking credentials into
# the Docker image layer.
# =============================================================================
set -e

OPENCLAW_CONFIG_DIR="/home/node/.config/openclaw"
OPENCLAW_SESSION_FILE="${OPENCLAW_CONFIG_DIR}/openclaw.json"

echo "[Node Beta] Boot sequence initiated at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# --- SESSION HYDRATION -------------------------------------------------------
if [ -n "$OPENCLAW_SESSION_JSON" ]; then
  echo "[Node Beta] OPENCLAW_SESSION_JSON detected. Hydrating ChatGPT Plus OAuth session..."
  mkdir -p "$OPENCLAW_CONFIG_DIR"
  printf '%s' "$OPENCLAW_SESSION_JSON" > "$OPENCLAW_SESSION_FILE"
  chmod 600 "$OPENCLAW_SESSION_FILE"
  BYTE_COUNT=$(wc -c < "$OPENCLAW_SESSION_FILE" | tr -d ' ')
  echo "[Node Beta] Session hydration: COMPLETE — ${BYTE_COUNT} bytes written to ${OPENCLAW_SESSION_FILE}"
else
  echo "[Node Beta] WARNING: OPENCLAW_SESSION_JSON is not set."
  echo "[Node Beta] Container will run in degraded mode (no ChatGPT Plus session)."
  echo "[Node Beta] Set OPENCLAW_SESSION_JSON in ClawCloud Run environment variables to enable."
fi

# --- HAND OFF TO MAIN PROCESS ------------------------------------------------
echo "[Node Beta] Handing off to main process: $@"
exec "$@"