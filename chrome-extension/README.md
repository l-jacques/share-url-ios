# Share URL — Chrome extension

Chrome (Manifest V3) counterpart of the iOS share extension. Talks to the same server
API as `share-api/NetworkManager.swift`.

## Features

- **Popup → Share**: current tab URL prefilled (editable), resolution picker
  (`GET /resolutions`, remembered), **Send** → `POST /download`.
- **Popup → Status**: `GET /status` list, polled every 3 s while open; **Clear history**
  → `POST /clear-history`.
- **Right-click** a page, link or video → *Send to Share URL* (uses saved resolution,
  shows a notification).
- **Settings** (⚙︎ or extension options): server URL, **Test** hits `GET /health`.
  Default `http://10.0.4.83:3000`. Stored in `chrome.storage.sync`.
- Green/red dot in popup header = server reachable or not.

## Install (unpacked)

1. `chrome://extensions` → enable **Developer mode**.
2. **Load unpacked** → select this `chrome-extension/` folder.
3. Pin the extension; open ⚙︎ to set the server URL if not the default.

After code changes: hit the reload ↻ icon on the extension card.

## Notes

- `host_permissions` covers `http://*/*` and `https://*/*` so any server URL works
  without CORS headers on the server.
- No build step, no dependencies — plain ES modules.
