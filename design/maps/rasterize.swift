#!/usr/bin/env swift
import AppKit
import Foundation

/// Rasterize map SVGs at their intrinsic pixel size into the iOS imagesets.
/// Usage: swift rasterize.swift [maps-dir assets-dir]

let mapsDir: URL
let assetsDir: URL
let args = CommandLine.arguments
if args.count == 1 {
    mapsDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    assetsDir = mapsDir
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("ios/BARTist/Assets.xcassets")
} else if args.count == 3 {
    mapsDir = URL(fileURLWithPath: args[1], isDirectory: true)
    assetsDir = URL(fileURLWithPath: args[2], isDirectory: true)
} else {
    fputs("usage: rasterize.swift [maps-dir assets-dir]\n", stderr)
    exit(1)
}

struct Job {
    let svg: String
    let imageset: String
    let png: String
}

let jobs = [
    Job(svg: "bart-map-daytime.svg", imageset: "MapDaytime.imageset", png: "bart-map-daytime.png"),
    Job(svg: "bart-map-daytime-dark.svg", imageset: "MapDaytime.imageset", png: "bart-map-daytime-dark.png"),
    Job(svg: "bart-map-evening.svg", imageset: "MapEvening.imageset", png: "bart-map-evening.png"),
    Job(svg: "bart-map-evening-dark.svg", imageset: "MapEvening.imageset", png: "bart-map-evening-dark.png"),
]

for job in jobs {
    let svgURL = mapsDir.appendingPathComponent(job.svg)
    let pngURL = assetsDir
        .appendingPathComponent(job.imageset)
        .appendingPathComponent(job.png)

    guard let image = NSImage(contentsOf: svgURL) else {
        fputs("failed to load \(svgURL.path)\n", stderr)
        exit(1)
    }

    let width = Int(image.size.width.rounded())
    let height = Int(image.size.height.rounded())
    guard width > 0, height > 0 else {
        fputs("invalid size for \(svgURL.path)\n", stderr)
        exit(1)
    }

    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fputs("failed to create bitmap for \(job.svg)\n", stderr)
        exit(1)
    }
    rep.size = NSSize(width: width, height: height)

    NSGraphicsContext.saveGraphicsState()
    guard let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
        fputs("failed to create context for \(job.svg)\n", stderr)
        exit(1)
    }
    NSGraphicsContext.current = ctx
    ctx.imageInterpolation = .high
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: width, height: height).fill()
    image.draw(
        in: NSRect(x: 0, y: 0, width: width, height: height),
        from: .zero,
        operation: .sourceOver,
        fraction: 1
    )
    NSGraphicsContext.restoreGraphicsState()

    guard let data = rep.representation(using: .png, properties: [:]) else {
        fputs("failed to encode \(pngURL.path)\n", stderr)
        exit(1)
    }
    try data.write(to: pngURL)
    print("wrote \(pngURL.path) (\(data.count) bytes, \(width)×\(height))")
}
