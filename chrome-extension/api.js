// Client for the Share URL server. Mirrors share-api/NetworkManager.swift.

export const DEFAULT_SERVER_URL = "http://10.0.4.83:3000";
export const DEFAULT_RESOLUTIONS = ["low", "medium", "high", "hd", "best"];

const PATHS = {
  download: "/download",
  status: "/status",
  clearHistory: "/clear-history",
  resolutions: "/resolutions",
  health: "/health",
};

/** Saved server URL without trailing slash, or the default. */
export async function getServerURL() {
  const { serverUrl } = await chrome.storage.sync.get("serverUrl");
  const url = (serverUrl ?? "").trim() || DEFAULT_SERVER_URL;
  return url.replace(/\/+$/, "");
}

export async function setServerURL(url) {
  await chrome.storage.sync.set({ serverUrl: url.trim() });
}

/** API token sent as `Authorization: Bearer`. Kept in storage.local: a secret, so not synced via the Google account. */
export async function getApiToken() {
  const { apiToken } = await chrome.storage.local.get("apiToken");
  return (apiToken ?? "").trim();
}

export async function setApiToken(token) {
  await chrome.storage.local.set({ apiToken: token.trim() });
}

export async function getResolution() {
  const { shareResolution } = await chrome.storage.sync.get("shareResolution");
  return shareResolution || "medium";
}

export async function setResolution(resolution) {
  await chrome.storage.sync.set({ shareResolution: resolution });
}

async function request(path, { method = "GET", body, timeoutMs = 60000, base } = {}) {
  const url = (base ?? (await getServerURL())) + path;
  const headers = {};
  if (body) headers["Content-Type"] = "application/json";
  const token = await getApiToken();
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(url, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(timeoutMs),
  });
  if (res.status === 401) throw new Error("Server refused the API token: set it in the extension settings");
  if (!res.ok) throw new Error(`Server responded ${res.status}`);
  return res;
}

/** POST /download — same payload as the iOS ShareData. */
export async function sendURL(url, resolution) {
  const res = await request(PATHS.download, {
    method: "POST",
    body: {
      id: crypto.randomUUID().toUpperCase(),
      url,
      name: "Shared Data",
      status: "Shared",
      resolution: resolution || "medium",
    },
  });
  return res.text();
}

/** GET /status → DownloadItem[] */
export async function fetchDownloads() {
  const res = await request(PATHS.status);
  return res.json();
}

/** POST /clear-history */
export async function clearHistory() {
  const res = await request(PATHS.clearHistory, { method: "POST" });
  const json = await res.json().catch(() => null);
  if (json && json.success === false && json.error) throw new Error(json.error);
}

/** GET /resolutions → string[] (falls back to defaults) */
export async function getAvailableResolutions() {
  try {
    const res = await request(PATHS.resolutions, { timeoutMs: 5000 });
    const json = await res.json();
    return Array.isArray(json?.options) ? json.options : DEFAULT_RESOLUTIONS;
  } catch {
    return DEFAULT_RESOLUTIONS;
  }
}

/** True when the server answers /health with 200. */
export async function isServerReachable(base) {
  try {
    const res = await fetch((base ?? (await getServerURL())).replace(/\/+$/, "") + PATHS.health, {
      signal: AbortSignal.timeout(5000),
    });
    return res.status === 200;
  } catch {
    return false;
  }
}

/** Stable key for lists (servers before Nov 2026 didn't send an id). */
export function listID(item) {
  return item.id ?? `${item.started}|${item.url ?? item.title}`;
}
