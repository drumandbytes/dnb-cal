#!/usr/bin/swift
// Generates Resources/AppIcon.icns from an SF Symbol. Re-run after tweaking below.
import AppKit

let symbolName = "calendar"
let iconset = "Resources/AppIcon.iconset"

func render(_ px: Int) -> Data? {
    let s = CGFloat(px)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()
    let radius = s * 0.22 // macOS squircle proportions
    let background = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: s, height: s), xRadius: radius, yRadius: radius)
    NSGradient(colors: [
        NSColor(calibratedRed: 0.10, green: 0.62, blue: 0.55, alpha: 1), // teal
        NSColor(calibratedRed: 0.10, green: 0.37, blue: 0.62, alpha: 1), // blue
    ])?.draw(in: background, angle: -45)

    let config = NSImage.SymbolConfiguration(pointSize: s * 0.5, weight: .semibold)
        .applying(NSImage.SymbolConfiguration(paletteColors: [.white]))
    if let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        symbol.draw(in: NSRect(x: (s - symbol.size.width) / 2, y: (s - symbol.size.height) / 2,
                               width: symbol.size.width, height: symbol.size.height))
    }
    image.unlockFocus()
    guard let tiff = image.tiffRepresentation else { return nil }
    return NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
}

try? FileManager.default.removeItem(atPath: iconset)
try FileManager.default.createDirectory(atPath: iconset, withIntermediateDirectories: true)
for (name, px) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128), ("128x128@2x", 256),
                   ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024)] {
    try render(px)?.write(to: URL(fileURLWithPath: "\(iconset)/icon_\(name).png"))
}
print("Wrote \(iconset). Run: iconutil -c icns \(iconset) -o Resources/AppIcon.icns")
