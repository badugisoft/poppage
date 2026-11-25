#!/usr/bin/env swift
import AppKit
import Foundation

// Generates Resources/AppIcon.icns using CoreGraphics/AppKit and iconutil.

let rootDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let resourcesDir = rootDir.appendingPathComponent("Resources", isDirectory: true)
let icnsURL = resourcesDir.appendingPathComponent("AppIcon.icns")

let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("PopPageIcon-\(UUID().uuidString)", isDirectory: true)
let iconsetURL = tempDir.appendingPathComponent("AppIcon.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)
try FileManager.default.createDirectory(at: resourcesDir, withIntermediateDirectories: true)

defer {
    try? FileManager.default.removeItem(at: tempDir)
}

func renderIcon(pixelSize: Int) -> Data {
    let size = CGFloat(pixelSize)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Failed to allocate bitmap rep for size \(pixelSize)")
    }

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
        fatalError("Failed to create graphics context")
    }
    NSGraphicsContext.current = context
    let cg = context.cgContext

    cg.clear(CGRect(x: 0, y: 0, width: size, height: size))

    // macOS Big Sur+ squircle container inset (~9.8% margin on each side)
    let inset = size * 0.098
    let tileRect = CGRect(x: inset, y: inset, width: size - inset * 2, height: size - inset * 2)
    let tileRadius = tileRect.width * 0.225
    let tilePath = NSBezierPath(roundedRect: tileRect, xRadius: tileRadius, yRadius: tileRadius)

    // Outer drop shadow for the app icon tile
    cg.saveGState()
    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
    shadow.shadowOffset = NSSize(width: 0, height: -size * 0.018)
    shadow.shadowBlurRadius = size * 0.04
    shadow.set()
    NSColor.white.setFill()
    tilePath.fill()
    cg.restoreGState()

    // Clip to squircle and draw blue-to-indigo diagonal gradient
    cg.saveGState()
    tilePath.addClip()

    let colors = [
        NSColor(srgbRed: 0.231, green: 0.510, blue: 0.965, alpha: 1.0).cgColor, // #3B82F6
        NSColor(srgbRed: 0.310, green: 0.275, blue: 0.898, alpha: 1.0).cgColor  // #4F46E5
    ] as CFArray
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 1.0]) {
        cg.drawLinearGradient(
            gradient,
            start: CGPoint(x: tileRect.minX, y: tileRect.maxY),
            end: CGPoint(x: tileRect.maxX, y: tileRect.minY),
            options: []
        )
    }

    // Subtle top rim highlight inside the squircle
    let rimPath = NSBezierPath(roundedRect: tileRect.insetBy(dx: size * 0.004, dy: size * 0.004), xRadius: tileRadius, yRadius: tileRadius)
    rimPath.lineWidth = max(1.0, size * 0.008)
    NSColor.white.withAlphaComponent(0.22).setStroke()
    rimPath.stroke()

    // Frosted macOS menu bar strip near top of tile
    let menuBarHeight = tileRect.height * 0.145
    let menuBarRect = CGRect(
        x: tileRect.minX,
        y: tileRect.maxY - menuBarHeight,
        width: tileRect.width,
        height: menuBarHeight
    )
    NSColor.white.withAlphaComponent(0.20).setFill()
    menuBarRect.fill()

    // Menu bar bottom hairline
    let hairline = CGRect(x: menuBarRect.minX, y: menuBarRect.minY, width: menuBarRect.width, height: max(1.0, size * 0.004))
    NSColor.white.withAlphaComponent(0.25).setFill()
    hairline.fill()

    // Status item indicator pill in the menu bar (centered)
    let pillWidth = tileRect.width * 0.12
    let pillHeight = menuBarHeight * 0.46
    let pillRect = CGRect(
        x: tileRect.midX - pillWidth / 2,
        y: menuBarRect.midY - pillHeight / 2,
        width: pillWidth,
        height: pillHeight
    )
    let pillPath = NSBezierPath(roundedRect: pillRect, xRadius: pillHeight / 2, yRadius: pillHeight / 2)
    NSColor.white.withAlphaComponent(0.95).setFill()
    pillPath.fill()

    // Popover card + upward pointer triangle
    let cardWidth = tileRect.width * 0.68
    let cardHeight = tileRect.height * 0.54
    let cardX = tileRect.midX - cardWidth / 2
    let arrowHeight = tileRect.height * 0.075
    let arrowHalfWidth = tileRect.width * 0.075
    let cardTopY = menuBarRect.minY - tileRect.height * 0.045
    let cardBodyTopY = cardTopY - arrowHeight
    let cardBottomY = cardBodyTopY - cardHeight
    let cardRadius = tileRect.width * 0.075

    let cardRect = CGRect(x: cardX, y: cardBottomY, width: cardWidth, height: cardHeight)

    // Combined popover bubble path (card + centered top arrow)
    let bubblePath = NSBezierPath()
    bubblePath.move(to: NSPoint(x: cardRect.minX + cardRadius, y: cardRect.minY))
    bubblePath.line(to: NSPoint(x: cardRect.maxX - cardRadius, y: cardRect.minY))
    bubblePath.appendArc(
        withCenter: NSPoint(x: cardRect.maxX - cardRadius, y: cardRect.minY + cardRadius),
        radius: cardRadius,
        startAngle: 270,
        endAngle: 0
    )
    bubblePath.line(to: NSPoint(x: cardRect.maxX, y: cardRect.maxY - cardRadius))
    bubblePath.appendArc(
        withCenter: NSPoint(x: cardRect.maxX - cardRadius, y: cardRect.maxY - cardRadius),
        radius: cardRadius,
        startAngle: 0,
        endAngle: 90
    )
    bubblePath.line(to: NSPoint(x: tileRect.midX + arrowHalfWidth, y: cardRect.maxY))
    bubblePath.line(to: NSPoint(x: tileRect.midX, y: cardTopY))
    bubblePath.line(to: NSPoint(x: tileRect.midX - arrowHalfWidth, y: cardRect.maxY))
    bubblePath.line(to: NSPoint(x: cardRect.minX + cardRadius, y: cardRect.maxY))
    bubblePath.appendArc(
        withCenter: NSPoint(x: cardRect.minX + cardRadius, y: cardRect.maxY - cardRadius),
        radius: cardRadius,
        startAngle: 90,
        endAngle: 180
    )
    bubblePath.line(to: NSPoint(x: cardRect.minX, y: cardRect.minY + cardRadius))
    bubblePath.appendArc(
        withCenter: NSPoint(x: cardRect.minX + cardRadius, y: cardRect.minY + cardRadius),
        radius: cardRadius,
        startAngle: 180,
        endAngle: 270
    )
    bubblePath.close()

    cg.saveGState()
    let cardShadow = NSShadow()
    cardShadow.shadowColor = NSColor.black.withAlphaComponent(0.24)
    cardShadow.shadowOffset = NSSize(width: 0, height: -size * 0.02)
    cardShadow.shadowBlurRadius = size * 0.045
    cardShadow.set()
    NSColor(srgbRed: 0.985, green: 0.988, blue: 1.0, alpha: 1.0).setFill()
    bubblePath.fill()
    cg.restoreGState()

    // Stylized webpage content inside popover card (only crisp at >= 32px, still clean at 16px)
    let padX = cardWidth * 0.11
    let innerX = cardRect.minX + padX
    let innerW = cardWidth - padX * 2

    // Accent hero block
    let heroH = cardHeight * 0.28
    let heroY = cardRect.maxY - cardHeight * 0.16 - heroH
    let heroRect = CGRect(x: innerX, y: heroY, width: innerW, height: heroH)
    let heroPath = NSBezierPath(roundedRect: heroRect, xRadius: cardRadius * 0.45, yRadius: cardRadius * 0.45)
    NSColor(srgbRed: 0.231, green: 0.510, blue: 0.965, alpha: 0.85).setFill()
    heroPath.fill()

    // Content lines
    let lineH = max(1.5, cardHeight * 0.095)
    let lineGap = cardHeight * 0.085
    let line1Y = heroY - lineGap - lineH
    let line2Y = line1Y - lineGap - lineH

    let line1Rect = CGRect(x: innerX, y: line1Y, width: innerW * 0.86, height: lineH)
    let line2Rect = CGRect(x: innerX, y: line2Y, width: innerW * 0.62, height: lineH)
    NSColor(srgbRed: 0.58, green: 0.64, blue: 0.72, alpha: 0.55).setFill()
    NSBezierPath(roundedRect: line1Rect, xRadius: lineH / 2, yRadius: lineH / 2).fill()
    NSColor(srgbRed: 0.58, green: 0.64, blue: 0.72, alpha: 0.35).setFill()
    NSBezierPath(roundedRect: line2Rect, xRadius: lineH / 2, yRadius: lineH / 2).fill()

    cg.restoreGState()
    NSGraphicsContext.restoreGraphicsState()

    guard let png = rep.representation(using: .png, properties: [:]) else {
        fatalError("Failed to encode PNG for size \(pixelSize)")
    }
    return png
}

let iconSpecs: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

for spec in iconSpecs {
    let data = renderIcon(pixelSize: spec.pixels)
    try data.write(to: iconsetURL.appendingPathComponent(spec.name))
}

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
process.arguments = ["-c", "icns", iconsetURL.path, "-o", icnsURL.path]
try process.run()
process.waitUntilExit()

guard process.terminationStatus == 0 else {
    fatalError("iconutil failed with exit code \(process.terminationStatus)")
}

print("Generated \(icnsURL.path)")
