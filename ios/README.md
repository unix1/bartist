# BARTist (native iOS)

SwiftUI iOS app for live [BART](https://www.bart.gov) departures and a zoomable system map. This is a native sibling of the Tauri/Vue app in the repo root. Bundle id is `app.bartist.native` so both can be installed at once.

It uses the official [BART API](https://www.bart.gov/schedules/developers/api). The bundled maps are BART’s [App Map](https://www.bart.gov/schedules/developers/maps), licensed under [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).

Requires [Xcode](https://developer.apple.com/xcode/) and [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`). Deployment target is iOS 17. Built with the iOS 26 SDK, system chrome uses Liquid Glass on 26+ and the classic bars on 17–18.

```sh
cd ios
make open          # regenerate the Xcode project and open it
make run           # build, boot the simulator, install, and launch
make simulators    # list available simulator names
```

`make run` defaults to `iPhone 17`. Override if that name is missing or duplicated:

```sh
xcrun simctl list devices available
xcrun simctl rename 01234567-890A-BCDE-F012-3456789ABCDE "iPhone 17 Pro iOS 26.5"
SIMULATOR='iPhone 17 Pro iOS 26.5' make run
```

`project.yml` is the project source of truth. `make generate` (also run by `open`, `build`, and `run`) writes `BARTist.xcodeproj`. Commit both.

Device runs need a Development Team in Xcode. Do not commit a `DEVELOPMENT_TEAM` value.

## License

BARTist is licensed under the [Apache License 2.0](../LICENSE).
