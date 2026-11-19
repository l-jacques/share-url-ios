# share-url

**Source of truth:** vault note `share-url-plan.md`
(`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/build_concierge/share-url-plan.md`).
Read it before changing behaviour. After each step: tick the roadmap and add a journal line.
Design decisions live there, not here — this file holds only stack, commands and code rules.

## Stack

- `share url/` — iOS app + share extension (SwiftUI), Xcode project `share-url.xcodeproj`
- `share-api/` — Swift package: `NetworkManager`, `ServerSettings`, models
- `chrome-extension/` — Chrome MV3 extension, vanilla ES modules, no build

## Commands

- Swift package tests: `cd share-api && swift test`
- Chrome extension: `chrome://extensions` → Developer mode → Load unpacked → `chrome-extension/`
- JS syntax check: `for f in chrome-extension/*.js; do node --input-type=module --check < $f; done`

## Code rules

- All clients use the same server API (see plan note). Change `share-api/NetworkManager.swift`
  and `chrome-extension/api.js` together.
