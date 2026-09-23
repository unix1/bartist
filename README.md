# BARTist

BARTist is a [BART](https://www.bart.gov) train schedule app built with [Tauri](https://tauri.app) for desktop and iOS.

## How it works

It uses the official [BART API](https://www.bart.gov/schedules/developers/api) to fetch stations and departure times, and includes a zoomable system map.

## Development

Requires Rust and Node.js.

```sh
npm install
npm run tauri dev
```

### iOS

Requires [Xcode](https://developer.apple.com/xcode/), [CocoaPods](https://cocoapods.org), and the Rust iOS targets (`aarch64-apple-ios`, `aarch64-apple-ios-sim`, `x86_64-apple-ios`).

```sh
npm run tauri ios init -- --ci
npm run tauri ios dev
```

Pass a simulator name to skip the device picker or avoid the default device, for example

```sh
npm run tauri ios dev -- "iPhone 17"
```

If multiple simulators share the same name you may need to rename to launch a specific one.

```sh
xcrun simctl list devices available
xcrun simctl rename 01234567-890A-BCDE-F012-3456789ABCDE "iPhone 17 Pro iOS 26.5"
```

To open Xcode run

```sh
npm run tauri ios build -- --open
```

## License

BARTist is licensed under the [Apache License 2.0](LICENSE).
