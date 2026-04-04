#!/usr/bin/env swift

import AppKit
import CoreGraphics

func generateIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let context = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let s = CGFloat(size)
    let rect = CGRect(x: 0, y: 0, width: s, height: s)

    // Rounded rectangle background with gradient
    let cornerRadius = s * 0.22
    let path = CGPath(roundedRect: rect.insetBy(dx: s * 0.02, dy: s * 0.02),
                      cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                      transform: nil)

    context.addPath(path)
    context.clip()

    // Dark gradient background (deep purple to dark blue)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradientColors = [
        CGColor(red: 0.15, green: 0.08, blue: 0.35, alpha: 1.0),
        CGColor(red: 0.08, green: 0.12, blue: 0.30, alpha: 1.0),
        CGColor(red: 0.05, green: 0.15, blue: 0.25, alpha: 1.0),
    ] as CFArray
    let gradientLocations: [CGFloat] = [0.0, 0.5, 1.0]

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: gradientLocations) {
        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: s),
                                   end: CGPoint(x: s, y: 0),
                                   options: [])
    }

    // Subtle inner glow
    context.setFillColor(CGColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 0.15))
    let glowRect = CGRect(x: s * 0.1, y: s * 0.4, width: s * 0.8, height: s * 0.5)
    context.fillEllipse(in: glowRect)

    // Draw "M↓" text — stylized markdown symbol
    let fontSize = s * 0.48
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)

    // "M" character
    let mAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor.white
    ]
    let mString = NSAttributedString(string: "M", attributes: mAttrs)
    let mSize = mString.size()
    let totalWidth = mSize.width + s * 0.08 + s * 0.18 // M + gap + arrow
    let startX = (s - totalWidth) / 2
    let textY = (s - mSize.height) / 2 - s * 0.02
    mString.draw(at: NSPoint(x: startX, y: textY))

    // Down arrow (↓) — representing markdown
    let arrowFont = NSFont.systemFont(ofSize: s * 0.38, weight: .medium)
    let arrowAttrs: [NSAttributedString.Key: Any] = [
        .font: arrowFont,
        .foregroundColor: NSColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
    ]
    let arrowString = NSAttributedString(string: "↓", attributes: arrowAttrs)
    let arrowX = startX + mSize.width + s * 0.02
    let arrowY = textY - s * 0.03
    arrowString.draw(at: NSPoint(x: arrowX, y: arrowY))

    // Subtle horizontal line accent at bottom
    context.setStrokeColor(CGColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 0.5))
    context.setLineWidth(s * 0.02)
    context.move(to: CGPoint(x: s * 0.2, y: s * 0.18))
    context.addLine(to: CGPoint(x: s * 0.8, y: s * 0.18))
    context.strokePath()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String, size: Int) {
    let resized = NSImage(size: NSSize(width: size, height: size))
    resized.lockFocus()
    image.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
               from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
               operation: .copy, fraction: 1.0)
    resized.unlockFocus()

    guard let tiffData = resized.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for size \(size)")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Generated: \(path)")
    } catch {
        print("Failed to write \(path): \(error)")
    }
}

let basePath = "MarkdownPreviewer/Assets.xcassets/AppIcon.appiconset"
let icon = generateIcon(size: 1024)

let sizes: [(Int, String)] = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

for (size, filename) in sizes {
    savePNG(icon, to: "\(basePath)/\(filename)", size: size)
}

print("Done! All icon sizes generated.")
