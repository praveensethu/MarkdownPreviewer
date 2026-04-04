#!/usr/bin/env swift

import AppKit
import CoreGraphics

func generateIcon(size: Int) -> Data? {
    let s = CGFloat(size)
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return nil }

    let rect = CGRect(x: 0, y: 0, width: s, height: s)

    // Rounded rectangle background
    let cornerRadius = s * 0.22
    let path = CGPath(roundedRect: rect.insetBy(dx: s * 0.02, dy: s * 0.02),
                      cornerWidth: cornerRadius, cornerHeight: cornerRadius,
                      transform: nil)
    context.addPath(path)
    context.clip()

    // Gradient background
    let gradientColors = [
        CGColor(red: 0.15, green: 0.08, blue: 0.35, alpha: 1.0),
        CGColor(red: 0.08, green: 0.12, blue: 0.30, alpha: 1.0),
        CGColor(red: 0.05, green: 0.15, blue: 0.25, alpha: 1.0),
    ] as CFArray

    if let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 0.5, 1.0]) {
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: s, y: 0), options: [])
    }

    // Subtle glow
    context.setFillColor(CGColor(red: 0.3, green: 0.2, blue: 0.6, alpha: 0.15))
    context.fillEllipse(in: CGRect(x: s * 0.1, y: s * 0.4, width: s * 0.8, height: s * 0.5))

    // Draw text using NSGraphicsContext
    let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
    NSGraphicsContext.current = nsContext

    let fontSize = s * 0.48
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let mAttrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
    let mString = NSAttributedString(string: "M", attributes: mAttrs)
    let mSize = mString.size()

    let arrowFont = NSFont.systemFont(ofSize: s * 0.38, weight: .medium)
    let arrowAttrs: [NSAttributedString.Key: Any] = [
        .font: arrowFont,
        .foregroundColor: NSColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 1.0)
    ]
    let arrowString = NSAttributedString(string: "↓", attributes: arrowAttrs)

    let totalWidth = mSize.width + s * 0.02 + arrowString.size().width
    let startX = (s - totalWidth) / 2
    let textY = (s - mSize.height) / 2 - s * 0.02

    mString.draw(at: NSPoint(x: startX, y: textY))
    arrowString.draw(at: NSPoint(x: startX + mSize.width + s * 0.02, y: textY - s * 0.03))

    NSGraphicsContext.current = nil

    // Bottom accent line
    context.setStrokeColor(CGColor(red: 0.55, green: 0.75, blue: 1.0, alpha: 0.5))
    context.setLineWidth(s * 0.02)
    context.move(to: CGPoint(x: s * 0.2, y: s * 0.18))
    context.addLine(to: CGPoint(x: s * 0.8, y: s * 0.18))
    context.strokePath()

    guard let cgImage = context.makeImage() else { return nil }
    let rep = NSBitmapImageRep(cgImage: cgImage)
    rep.size = NSSize(width: size, height: size)
    return rep.representation(using: .png, properties: [:])
}

let basePath = "MarkdownPreviewer/Assets.xcassets/AppIcon.appiconset"

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
    if let data = generateIcon(size: size) {
        let path = "\(basePath)/\(filename)"
        try! data.write(to: URL(fileURLWithPath: path))
        print("Generated \(size)x\(size): \(filename)")
    }
}
print("Done!")
