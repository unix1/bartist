# AGENTS.md

BARTist is a small [Tauri 2](https://tauri.app) desktop app for BART train departures and a zoomable system map. Keep it extremely simple.

## Stack

- **Frontend:** vanilla HTML / CSS / JS in `src/`. No bundler, no framework, no TypeScript.
- **Shell:** Tauri 2 in `src-tauri/`. Rust is a thin window host (`bartist_lib::run`). Do not add commands, plugins, or crates unless the UI cannot do the work.
- **Data:** official [BART API](https://www.bart.gov/schedules/developers/api) (`https://api.bart.gov/api/`) with `json=y`. Default station is `12TH`. Use the public key published on that page.
- **License:** Apache 2.0.

## Layout

- `src/index.html`, `src/main.js`, `src/styles.css` — all app behavior and UI
- `src/assets/BART_cc_map.png` — bundled system map
- `src-tauri/tauri.conf.json` — window, CSP, bundle id `net.unix1.bartist`
- Frontend is served as static files (`frontendDist: ../src`)

## Features

Two tabs, matching the old Qt/QML app:

1. **Trains** — station picker overlay, then destination codes with car length and minutes (`Leaving` → “leaving now”).
2. **Map** — pinch / wheel zoom of the bundled map; double-click resets.

BART’s JSON sometimes returns one object instead of an array. Always normalize with `asArray`.

If you change API hosts, update CSP `connect-src` in `tauri.conf.json` (`https://api.bart.gov` is required today).

## Commands

```sh
npm install
npm run tauri dev
```

This is a native Tauri window. Do not verify by serving `src/` with Python, Vite, or a browser. Use `npm run tauri dev`.

## Conventions

- Prefer small, local edits. Do not introduce React, Vue, Vite, or extra Rust commands for work the frontend already does.
- Build DOM with `createElement` / `textContent`, not `innerHTML`.
- Keep the UI compact and phone-like (window is 420×780).
- Do not commit unless asked.
