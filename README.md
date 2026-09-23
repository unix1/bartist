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

Pass a simulator name to skip the device picker, for example `npm run tauri ios dev "iPhone 17"`.

## License

BARTist is licensed under the [Apache License 2.0](LICENSE).
