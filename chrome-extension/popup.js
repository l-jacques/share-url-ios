import {
  sendURL,
  fetchDownloads,
  clearHistory,
  getAvailableResolutions,
  getResolution,
  setResolution,
  isServerReachable,
  getServerURL,
  listID,
} from "./api.js";

const $ = (id) => document.getElementById(id);
const POLL_MS = 3000;
let pollTimer = null;

// ---------- Tabs ----------
document.querySelectorAll(".tabs button").forEach((btn) => {
  btn.addEventListener("click", () => showTab(btn.dataset.tab));
});

function showTab(name) {
  document.querySelectorAll(".tabs button").forEach((b) => b.classList.toggle("active", b.dataset.tab === name));
  $("tab-share").classList.toggle("hidden", name !== "share");
  $("tab-status").classList.toggle("hidden", name !== "status");
  clearInterval(pollTimer);
  if (name === "status") {
    loadDownloads();
    pollTimer = setInterval(loadDownloads, POLL_MS);
  }
}

$("open-options").addEventListener("click", () => chrome.runtime.openOptionsPage());

// ---------- Toasts ----------
function toast(el, message, kind) {
  el.textContent = message;
  el.className = `toast ${kind}`;
}

// ---------- Share tab ----------
async function initShare() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (tab?.url && /^https?:/.test(tab.url)) $("url").value = tab.url;

  const [options, saved] = await Promise.all([getAvailableResolutions(), getResolution()]);
  const select = $("resolution");
  select.innerHTML = "";
  for (const opt of options) select.add(new Option(opt, opt, false, opt === saved));
  if (!options.includes(saved)) select.value = options.includes("medium") ? "medium" : options[0];
  select.addEventListener("change", () => setResolution(select.value));
}

$("send").addEventListener("click", async () => {
  const url = $("url").value.trim();
  if (!url) return toast($("share-toast"), "Enter a URL first.", "err");
  try {
    new URL(url);
  } catch {
    return toast($("share-toast"), "That doesn't look like a valid URL.", "err");
  }

  const btn = $("send");
  btn.disabled = true;
  btn.textContent = "Sending…";
  try {
    await sendURL(url, $("resolution").value);
    toast($("share-toast"), "Sent! Check the Status tab for progress.", "ok");
  } catch (err) {
    toast($("share-toast"), `Failed: ${err.message || err}`, "err");
  } finally {
    btn.disabled = false;
    btn.textContent = "Send";
  }
});

// ---------- Status tab ----------
function statusKind(status) {
  const s = (status || "").toLowerCase();
  if (s.includes("error")) return "err";
  if (s.includes("progress")) return "warn";
  return "ok";
}

function formatDate(value) {
  if (!value) return "";
  const d = new Date(value);
  return isNaN(d) ? value : d.toLocaleString();
}

function renderItem(item) {
  const li = document.createElement("li");
  li.className = "item";
  li.dataset.id = listID(item);

  const title = document.createElement("div");
  title.className = "title";
  title.textContent = item.title || item.url || "Untitled";
  title.title = item.url || item.title || "";

  const meta = document.createElement("div");
  meta.className = "meta";
  const badge = document.createElement("span");
  const kind = statusKind(item.status);
  badge.className = `badge ${kind}`;
  badge.textContent = item.status;
  meta.append(badge);
  if (item.resolution) meta.append(Object.assign(document.createElement("span"), { textContent: item.resolution }));
  meta.append(Object.assign(document.createElement("span"), { textContent: formatDate(item.ended || item.started) }));

  li.append(title, meta);
  if (kind === "warn") li.append(Object.assign(document.createElement("div"), { className: "progress" }));
  if (item.errored) li.append(Object.assign(document.createElement("div"), { className: "error", textContent: item.errored }));
  return li;
}

async function loadDownloads() {
  const list = $("downloads");
  try {
    const items = await fetchDownloads();
    items.sort((a, b) => String(b.started).localeCompare(String(a.started)));
    list.replaceChildren(...items.map(renderItem));
    if (!items.length) list.replaceChildren(Object.assign(document.createElement("li"), { className: "empty", textContent: "No downloads yet." }));
    $("status-toast").classList.add("hidden");
  } catch (err) {
    toast($("status-toast"), `Can't load status: ${err.message || err}`, "err");
  }
}

$("refresh").addEventListener("click", loadDownloads);
$("clear").addEventListener("click", async () => {
  if (!confirm("Clear download history on the server?")) return;
  try {
    await clearHistory();
    await loadDownloads();
  } catch (err) {
    toast($("status-toast"), `Clear failed: ${err.message || err}`, "err");
  }
});

// ---------- Server reachability ----------
async function checkServer() {
  const dot = $("server-dot");
  const base = await getServerURL();
  const ok = await isServerReachable(base);
  dot.className = `dot ${ok ? "ok" : "err"}`;
  dot.title = `${base} — ${ok ? "reachable" : "unreachable"}`;
}

initShare();
checkServer();
