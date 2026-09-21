# AGENTS.md

BARTist is a small [Tauri 2](https://tauri.app) app for BART train departures and a zoomable system map, on desktop and iOS. Keep it extremely simple.

## Stack

- **Frontend:** Vue 3 + Vite in `src/`. Import npm packages normally. Do not vendor libraries into `src/`.
- **Shell:** Tauri 2 in `src-tauri/`. Rust is a thin window host (`bartist_lib::run`). Do not add commands, plugins, or crates unless the UI cannot do the work.
- **Data:** official [BART API](https://www.bart.gov/schedules/developers/api) (`https://api.bart.gov/api/`) with `json=y`. Default station is `12TH`. Use the public key published on that page.
- **License:** Apache 2.0.

## Layout

- `src/main.js`, `src/App.vue`, `src/styles.css` — shell and shared styles
- `src/api.js` — BART fetch helpers
- `src/components/TrainsView.vue`, `src/components/MapView.vue`
- `src/assets/BART_cc_map.png` — bundled system map
- `src-tauri/tauri.conf.json` — window, CSP, bundle id `app.bartist`
- `src-tauri/Info.ios.plist` — iOS orientation and status bar

## Features

Two tabs, matching the old Qt/QML app:

1. **Trains** — station picker overlay, then destination codes with car length and minutes (`Leaving` → “leaving now”).
2. **Map** — bundled image fitted to the pane. Pan/zoom uses [`@panzoom/panzoom`](https://github.com/timmywil/panzoom): pinch or wheel to zoom, drag only when zoomed, keep the image on screen, double-click to zoom/reset. Do not enable webview page zoom.

BART’s JSON sometimes returns one object instead of an array. Always normalize with `asArray`.

If you change API hosts, update CSP `connect-src` in `tauri.conf.json` (`https://api.bart.gov` is required today).

## Commands

```sh
npm install
npm run tauri dev
npm run tauri ios init -- --ci
npm run tauri ios dev
```

Desktop is a native Tauri window; verify with `npm run tauri dev`. iOS uses the same UI in a WKWebView; verify with `npm run tauri ios dev` on the Simulator.

The generated Xcode project lives in `src-tauri/gen/` (gitignored). Run `tauri ios init` after a fresh clone.

## Conventions

- Prefer small, local edits. No router, Pinia, or TypeScript unless asked.
- Keep the UI compact and phone-like (desktop window is 420×780). Respect iOS safe areas.
- Do not commit unless asked.
