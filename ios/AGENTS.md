# AGENTS.md

SwiftUI iOS app for BART train departures and a zoomable system map. Keep it extremely simple.

## Stack

- **UI:** SwiftUI in `BARTist/`. iPhone only, portrait, deployment target 17.0.
- **Project:** [XcodeGen](https://github.com/yonaskolb/XcodeGen) `project.yml` generates `BARTist.xcodeproj`. Commit both. Do not hand-edit the pbxproj when `project.yml` can do it.
- **Data:** official [BART API](https://www.bart.gov/schedules/developers/api) (`https://api.bart.gov/api/`) with `json=y`. Default station is `12TH`. Use the public key published on that page.
- **Bundle id:** `app.bartist`.
- **License:** Apache 2.0 (repo root).

## Layout

- `BARTist/BARTistApp.swift`, `RootView.swift` — `TabView` (Trains / Map)
- `BARTist/BartAPI.swift` — BART fetch helpers
- `BARTist/TrainsView.swift`, `MapView.swift`, `BrandTitle.swift`
- `BARTist/Assets.xcassets` — app icon, brand icon, daytime/evening maps (CC BY 3.0)
- `project.yml` — XcodeGen spec
- `Makefile` — generate, build, run, open, screenshots
- `BARTistUITests/` — Fastlane snapshot UI tests
- `fastlane/` — Snapfile and screenshots lane

## Features

Two tabs:

1. **Trains** — pinned `[icon] Trains` title, pinned station chip (truncates long names, picker scrolls to the current station), destination codes with car length and minutes (`Leaving` → “leaving now”). Only the departure list scrolls; pull-to-refresh is on that list.
2. **Map** — `[icon] Map` title aligned with Trains. Daytime or evening bundled image fitted to the pane, defaulting to evening from 9pm–3am Pacific. Pinch or double-tap to zoom, pan when zoomed, keep the image on screen. Day/night cross-fades. Credit (© BART · CC BY 3.0) stays on the image’s bottom-right.

BART’s JSON sometimes returns one object instead of an array. Always normalize with `FlexibleArray`.

Do not set `UIDesignRequiresCompatibility`. System `TabView` / bars pick up Liquid Glass on iOS 26 automatically.

## Commands

From `ios/`:

```sh
make generate
make open
make build
make run
make simulators
make screenshots   # Fastlane snapshot: Embarcadero trains, station picker, map
```

`SIMULATOR` defaults to `iPhone 17`. `make run` writes build products to `.derived/` (gitignored). Verify on the Simulator with `make run`, or `make open` and Run in Xcode.

## Conventions

- Prefer small, local edits. No extra frameworks, SPM packages, or CocoaPods unless asked.
- Keep the UI compact and phone-like. Respect safe areas. Do not repeat the app name as a large title; use the brand icon plus the tab name.
- Do not commit unless asked. Do not commit a `DEVELOPMENT_TEAM` or signing files.
