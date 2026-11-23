import { getServerURL, setServerURL, getApiToken, setApiToken, isServerReachable, DEFAULT_SERVER_URL } from "./api.js";

const input = document.getElementById("server");
const tokenInput = document.getElementById("token");
const toastEl = document.getElementById("toast");

function toast(message, kind) {
  toastEl.textContent = message;
  toastEl.className = `toast ${kind}`;
}

function normalized() {
  return input.value.trim().replace(/\/+$/, "") || DEFAULT_SERVER_URL;
}

getServerURL().then((url) => (input.value = url));
getApiToken().then((token) => (tokenInput.value = token));

document.getElementById("test").addEventListener("click", async () => {
  toast("Checking…", "ok");
  const ok = await isServerReachable(normalized());
  toast(ok ? "Server reachable ✓" : "Server unreachable (GET /health failed)", ok ? "ok" : "err");
});

document.getElementById("save").addEventListener("click", async () => {
  const url = normalized();
  try {
    new URL(url);
  } catch {
    return toast("Invalid URL.", "err");
  }
  await setServerURL(url);
  await setApiToken(tokenInput.value);
  input.value = url;
  toast("Saved.", "ok");
});
