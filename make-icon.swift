import Cocoa

// Renders a coffee-cup app icon at all required sizes into icon.iconset/

let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16), ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32), ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128), ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256), ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024),
]

let outDir = "icon.iconset"
try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func render(_ px: Int) -> Data? {
    let s = CGFloat(px)
    guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { return nil }
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    // squircle background with warm coffee gradient
    let inset = s * 0.06
    let rect = NSRect(x: inset, y: inset, width: s - inset*2, height: s - inset*2)
    let radius = rect.width * 0.225
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    let grad = NSGradient(colors: [
        NSColor(srgbRed: 0.91, green: 0.64, blue: 0.30, alpha: 1),   // warm amber
        NSColor(srgbRed: 0.55, green: 0.35, blue: 0.17, alpha: 1)])  // coffee brown
    grad?.draw(in: path, angle: -90)

    // white cup symbol, centered
    let cfg = NSImage.SymbolConfiguration(pointSize: s * 0.5, weight: .regular)
        .applying(.init(paletteColors: [.white]))
    if let sym = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
        .withSymbolConfiguration(cfg) {
        let sz = sym.size
        let scale = (s * 0.5) / max(sz.width, sz.height)
        let w = sz.width * scale, h = sz.height * scale
        sym.draw(in: NSRect(x: (s - w)/2, y: (s - h)/2, width: w, height: h))
    }

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])
}

for (name, px) in sizes {
    if let data = render(px) {
        try? data.write(to: URL(fileURLWithPath: "\(outDir)/\(name)"))
        print("wrote \(name) (\(px)px)")
    } else {
        print("FAILED \(name)")
    }
}
