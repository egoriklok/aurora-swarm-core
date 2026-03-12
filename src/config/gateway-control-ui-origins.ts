import type { OpenClawConfig } from "./config.js";
import { DEFAULT_GATEWAY_PORT } from "./paths.js";

export type GatewayNonLoopbackBindMode = "lan" | "tailnet" | "custom";

const CONTROL_UI_HOST_HEADER_ORIGIN_FALLBACK_ENV_VARS = [
  "OPENCLAW_GATEWAY_CONTROL_UI_DANGEROUSLY_ALLOW_HOST_HEADER_ORIGIN_FALLBACK",
  "CLAWDBOT_GATEWAY_CONTROL_UI_DANGEROUSLY_ALLOW_HOST_HEADER_ORIGIN_FALLBACK",
] as const;

function parseOptionalBooleanEnv(value: string | undefined): boolean | undefined {
  const normalized = value?.trim().toLowerCase();
  if (!normalized) {
    return undefined;
  }
  if (normalized === "1" || normalized === "true" || normalized === "yes" || normalized === "on") {
    return true;
  }
  if (normalized === "0" || normalized === "false" || normalized === "no" || normalized === "off") {
    return false;
  }
  return undefined;
}

export function isGatewayNonLoopbackBindMode(bind: unknown): bind is GatewayNonLoopbackBindMode {
  return bind === "lan" || bind === "tailnet" || bind === "custom";
}

export function resolveControlUiHostHeaderOriginFallback(
  config: Pick<OpenClawConfig, "gateway">,
  env: NodeJS.ProcessEnv = process.env,
): boolean {
  const configured = config.gateway?.controlUi?.dangerouslyAllowHostHeaderOriginFallback;
  if (configured === true) {
    return true;
  }
  if (configured === false) {
    return false;
  }
  for (const envVar of CONTROL_UI_HOST_HEADER_ORIGIN_FALLBACK_ENV_VARS) {
    const parsed = parseOptionalBooleanEnv(env[envVar]);
    if (parsed !== undefined) {
      return parsed;
    }
  }
  return false;
}

export function hasConfiguredControlUiAllowedOrigins(params: {
  allowedOrigins: unknown;
  dangerouslyAllowHostHeaderOriginFallback: unknown;
}): boolean {
  if (params.dangerouslyAllowHostHeaderOriginFallback === true) {
    return true;
  }
  return (
    Array.isArray(params.allowedOrigins) &&
    params.allowedOrigins.some((origin) => typeof origin === "string" && origin.trim().length > 0)
  );
}

export function resolveGatewayPortWithDefault(
  port: unknown,
  fallback = DEFAULT_GATEWAY_PORT,
): number {
  return typeof port === "number" && port > 0 ? port : fallback;
}

export function buildDefaultControlUiAllowedOrigins(params: {
  port: number;
  bind: unknown;
  customBindHost?: string;
}): string[] {
  const origins = new Set<string>([
    `http://localhost:${params.port}`,
    `http://127.0.0.1:${params.port}`,
  ]);
  const customBindHost = params.customBindHost?.trim();
  if (params.bind === "custom" && customBindHost) {
    origins.add(`http://${customBindHost}:${params.port}`);
  }
  return [...origins];
}

export function ensureControlUiAllowedOriginsForNonLoopbackBind(
  config: OpenClawConfig,
  opts?: { defaultPort?: number; requireControlUiEnabled?: boolean; env?: NodeJS.ProcessEnv },
): {
  config: OpenClawConfig;
  seededOrigins: string[] | null;
  bind: GatewayNonLoopbackBindMode | null;
} {
  const bind = config.gateway?.bind;
  if (!isGatewayNonLoopbackBindMode(bind)) {
    return { config, seededOrigins: null, bind: null };
  }
  if (opts?.requireControlUiEnabled && config.gateway?.controlUi?.enabled === false) {
    return { config, seededOrigins: null, bind };
  }
  if (
    hasConfiguredControlUiAllowedOrigins({
      allowedOrigins: config.gateway?.controlUi?.allowedOrigins,
      dangerouslyAllowHostHeaderOriginFallback: resolveControlUiHostHeaderOriginFallback(
        config,
        opts?.env,
      ),
    })
  ) {
    return { config, seededOrigins: null, bind };
  }

  const port = resolveGatewayPortWithDefault(config.gateway?.port, opts?.defaultPort);
  const seededOrigins = buildDefaultControlUiAllowedOrigins({
    port,
    bind,
    customBindHost: config.gateway?.customBindHost,
  });
  return {
    config: {
      ...config,
      gateway: {
        ...config.gateway,
        controlUi: {
          ...config.gateway?.controlUi,
          allowedOrigins: seededOrigins,
        },
      },
    },
    seededOrigins,
    bind,
  };
}
