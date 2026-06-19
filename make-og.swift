import Cocoa

// Renders a 1200x630 Open Graph share image -> og-image.png

let W = 1200, H = 630
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

// dark background
NSColor(srgbRed: 0.039, green: 0.039, blue: 0.043, alpha: 1).setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

// soft amber glow top-left
if let glow = NSGradient(colors: [
    NSColor(srgbRed: 0.91, green: 0.64, blue: 0.30, alpha: 0.20),
    NSColor(srgbRed: 0.91, green: 0.64, blue: 0.30, alpha: 0.0)]) {
    glow.draw(in: NSBezierPath(ovalIn: NSRect(x: -200, y: 200, width: 900, height: 700)),
              relativeCenterPosition: NSPoint(x: 0, y: 0))
}

// cup squircle (right side)
let s: CGFloat = 300
let cx: CGFloat = 900, cy: CGFloat = CGFloat(H)/2
let rect = NSRect(x: cx - s/2, y: cy - s/2, width: s, height: s)
let path = NSBezierPath(roundedRect: rect, xRadius: s*0.225, yRadius: s*0.225)
NSGradient(colors: [NSColor(srgbRed: 0.91, green: 0.64, blue: 0.30, alpha: 1),
                    NSColor(srgbRed: 0.55, green: 0.35, blue: 0.17, alpha: 1)])?.draw(in: path, angle: -90)
let cfg = NSImage.SymbolConfiguration(pointSize: s*0.5, weight: .regular)
    .applying(.init(paletteColors: [.white]))
if let sym = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: nil)?
    .withSymbolConfiguration(cfg) {
    let sz = sym.size, sc = (s*0.5)/max(sz.width, sz.height)
    let w = sz.width*sc, h = sz.height*sc
    sym.draw(in: NSRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
}

func draw(_ t: String, x: CGFloat, y: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight) {
    let p = NSMutableParagraphStyle(); p.alignment = .left
    let a: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color, .paragraphStyle: p]
    (t as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: a)
}

// text block (left). NOTE: AppKit origin is bottom-left.
let lx: CGFloat = 90
draw("☕ KeepAwake", x: lx, y: 410, size: 46, color: NSColor(srgbRed: 0.91, green: 0.64, blue: 0.30, alpha: 1), weight: .bold)
draw("Keep your Mac awake.", x: lx, y: 320, size: 64, color: .white, weight: .heavy)
draw("Even with the lid closed.", x: lx, y: 244, size: 64, color: .white, weight: .heavy)
draw("Free & open-source. No Mac App Store, no Apple ID.", x: lx, y: 180, size: 28,
     color: NSColor(white: 0.66, alpha: 1), weight: .regular)

NSGraphicsContext.restoreGraphicsState()
try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "og-image.png"))
print("wrote og-image.png (\(W)x\(H))")
