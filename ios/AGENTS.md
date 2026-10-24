# AGENTS.md

SwiftUI iOS app for BART train departures and a zoomable system map. Keep it extremely simple.

## Stack

- **UI:** SwiftUI in `BARTist/`. iPhone only, portrait, deployment target 17.0.
- **Project:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) `project.yml` generates `BARTist.xcodeproj`. Commit both. Do not hand-edit the pbxproj when `project.yml` can do it.
- **Data:** official [BART API](https://www.bart.gov/schedules/developers/api) (`https://api.bart.gov/api/`) with `json=y`. Default station is `12TH`. Use the public key published on that page.
- **Bundle id:** `app.bartist`.
- **License:** Apache 2.0 (repo root).

## Layout

- `BARTist/BARTistApp.swift`, `RootView.swift` — `TabView` (Trains / Map / Settings)
- `BARTist/BartAPI.swift` — BART fetch helpers
- `BARTist/TrainsView.swift`, `MapView.swift`, `SettingsView.swift`, `BrandTitle.swift`, `Palette.swift`
- `BARTist/Assets.xcassets` — app icon, brand icon, daytime/evening maps in light and dark as 2052 PNGs (derivative of BART’s App Map, CC BY 3.0). SVG sources live in `../design/maps/`; `make maps` rasterizes them into the imagesets.
- `project.yml` — XcodeGen spec
- `Makefile` — generate, build, run, open, test, screenshots, maps
- `BARTistTests/` — unit tests (`make test`)
- `BARTistUITests/` — Fastlane snapshot UI tests (`make screenshots`); add more UI tests here later
- `fastlane/` — Snapfile and screenshots lane
- `../.github/workflows/test.yml` — GitHub Actions: `make test` on `macos-latest`

## Features

Three tabs:

1. **Trains** — pinned `[icon] Trains` title, pinned station chip (truncates long names, picker scrolls to the current station), destination codes with car length and minutes (`Leaving` → “leaving now”). Only the departure list scrolls; pull-to-refresh is on that list. On iOS 27.1+, an `ArrangementView` split (horizontal axis only) keeps that list phone-width and shows the map beside it when the canvas is wider than it is tall (open iPhone Duo). An active hinge division (half-fold) drops the list width cap so each pane can fill a side of the fold. When the window is wider than it is tall (open or half-open Duo in landscape), tab titles are centered on their pane and the brand icon is hidden; the Map tab also centers the map under its title. Any other pose keeps `[icon] Title` left-aligned. Folded / portrait stays list-only; the Map tab is still the full map.
2. **Map** — `[icon] Map` title aligned with Trains. Daytime or evening bundled PNG fitted to the pane, defaulting to evening from 9pm–3am Pacific. Dark appearance uses the dark PNG. Pinch or double-tap to zoom, pan when zoomed, keep the map on screen. Day/night cross-fades. A small unlinked “© BARTist” sits on the map’s bottom-right.
3. **Settings** — pinned `[icon] Settings` title. Appearance (System / Light / Dark) is stored in `bartist.appearance` and applied with `preferredColorScheme`. Auto refresh (`bartist.autoRefresh`, default on) reloads the trains list every 30 seconds only while that tab is selected and the app is in the foreground. Colors live in `Palette`. A bottom About group opens a page: app icon (top-aligned) + name, tagline, version, and copyright; App Store rate / website / privacy links; then open-source copy with license, source, and map attribution (based on BART’s official maps under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)).

BART’s JSON sometimes returns one object instead of an array. Always normalize with `FlexibleArray`. `etd` can also repeat the same destination abbreviation; group those rows, sort trains by arrival, and keep the next three.

Do not set `UIDesignRequiresCompatibility`. System `TabView` / bars pick up Liquid Glass on iOS 26 automatically.

## Commands

From `ios/`:

```sh
make generate
make open
make build
make run
make test          # unit tests only (`BARTistTests`)
make simulators
make screenshots   # Fastlane snapshot: light+dark Trains, Stations, Map, Settings
make maps          # rasterize ../design/maps SVGs into imageset PNGs
```

`SIMULATOR` defaults to `iPhone 17`. `make run` writes build products to `.derived/` (gitignored). Verify on the Simulator with `make run`, or `make open` and Run in Xcode. `make test` is unit tests only; Fastlane snapshots stay on `make screenshots`. Functional UI tests can join `BARTistUITests` later without changing `make test`. Push CI runs `make test` on GitHub-hosted `macos-latest` (free for this public repo).

## Conventions

- Prefer small, local edits. No extra frameworks, SPM packages, or CocoaPods unless asked.
- Keep the UI compact and phone-like. Respect safe areas. Do not repeat the app name as a large title; use the brand icon plus the tab name.
- Do not commit unless asked. Do not commit a `DEVELOPMENT_TEAM` or signing files.
