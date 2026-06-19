import Cocoa

// Renders a macOS-style "screenshot" of the KeepAwake menu -> screenshot.png

let W = 1200, H = 760
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { exit(1) }
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
let ctx = NSGraphicsContext.current!.cgContext

func rrect(_ r: NSRect, _ rad: CGFloat) -> NSBezierPath { NSBezierPath(roundedRect: r, xRadius: rad, yRadius: rad) }
// top-origin helper (AppKit is bottom-left)
func ty(_ top: CGFloat) -> CGFloat { CGFloat(H) - top }
func text(_ s: String, x: CGFloat, top: CGFloat, size: CGFloat, color: NSColor, weight: NSFont.Weight = .regular) {
    let a: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color]
    let h = NSFont.systemFont(ofSize: size).ascender - NSFont.systemFont(ofSize: size).descender
    (s as NSString).draw(at: NSPoint(x: x, y: ty(top) - h), withAttributes: a)
}

// desktop background (soft gradient + amber glow)
NSGradient(colors: [NSColor(srgbRed:0.10,green:0.10,blue:0.12,alpha:1),
                    NSColor(srgbRed:0.04,green:0.04,blue:0.05,alpha:1)])?
    .draw(in: NSRect(x:0,y:0,width:W,height:H), angle: -90)
if let g = NSGradient(colors:[NSColor(srgbRed:0.91,green:0.64,blue:0.30,alpha:0.18),
                              NSColor(srgbRed:0.91,green:0.64,blue:0.30,alpha:0)]) {
    g.draw(in: NSBezierPath(ovalIn: NSRect(x:600,y:300,width:900,height:700)), relativeCenterPosition: .zero)
}

// menu bar strip
NSColor(white:0,alpha:0.32).setFill(); NSRect(x:0,y:ty(40),width:CGFloat(W),height:40).fill()
text("KeepAwake", x: 24, top: 11, size: 14, color: NSColor(white:1,alpha:0.85), weight: .semibold)
// right-side menu bar items + our cup icon (highlighted)
let cupX: CGFloat = 980
// highlight chip behind cup (menu open state)
NSColor(srgbRed:0.91,green:0.64,blue:0.30,alpha:0.9).setFill()
rrect(NSRect(x: cupX-8, y: ty(36), width: 36, height: 32), 7).fill()
func symbol(_ name: String, x: CGFloat, top: CGFloat, pt: CGFloat, color: NSColor) {
    let cfg = NSImage.SymbolConfiguration(pointSize: pt, weight: .regular).applying(.init(paletteColors:[color]))
    if let s = NSImage(systemSymbolName: name, accessibilityDescription: nil)?.withSymbolConfiguration(cfg) {
        let sz = s.size; s.draw(in: NSRect(x:x, y: ty(top)-sz.height, width: sz.width, height: sz.height))
    }
}
symbol("cup.and.saucer.fill", x: cupX, top: 9, pt: 17, color: NSColor(srgbRed:0.10,green:0.07,blue:0.02,alpha:1))
text("100% 􀛨   Wed 10:25􀋥", x: CGFloat(W)-225, top: 11, size: 14, color: NSColor(white:1,alpha:0.8))

// ---- dropdown menu panel ----
let px: CGFloat = 858, pw: CGFloat = 300, ptop: CGFloat = 52
struct Row { let label: String; let kind: Int }  // 0 normal,1 check,2 sep,3 highlight,4 header
let rows: [Row] = [
    Row(label:"Keep running with lid closed", kind:1),
    Row(label:"", kind:2),
    Row(label:"15 minutes", kind:3),
    Row(label:"30 minutes", kind:0),
    Row(label:"1 hour", kind:0),
    Row(label:"Indefinitely", kind:0),
    Row(label:"Custom…", kind:0),
    Row(label:"", kind:2),
    Row(label:"Quit KeepAwake", kind:0),
]
// compute height
var ph: CGFloat = 14
for r in rows { ph += (r.kind == 2 ? 13 : 36) }
ph += 6
// shadow + panel
ctx.saveGState()
ctx.setShadow(offset: CGSize(width:0,height:-18), blur: 50, color: NSColor(white:0,alpha:0.55).cgColor)
NSColor(srgbRed:0.13,green:0.13,blue:0.15,alpha:0.98).setFill()
rrect(NSRect(x:px,y:ty(ptop+ph),width:pw,height:ph), 13).fill()
ctx.restoreGState()
NSColor(white:1,alpha:0.09).setStroke()
let bp = rrect(NSRect(x:px,y:ty(ptop+ph),width:pw,height:ph),13); bp.lineWidth=1; bp.stroke()

var yt = ptop + 12
let lx = px + 36
for r in rows {
    if r.kind == 2 {
        NSColor(white:1,alpha:0.10).setFill()
        NSRect(x:px+12,y:ty(yt+6),width:pw-24,height:1).fill()
        yt += 13; continue
    }
    if r.kind == 3 {  // highlighted row
        if let g = NSGradient(colors:[NSColor(srgbRed:0.93,green:0.66,blue:0.32,alpha:1),
                                      NSColor(srgbRed:0.80,green:0.52,blue:0.22,alpha:1)]) {
            g.draw(in: rrect(NSRect(x:px+8,y:ty(yt+32),width:pw-16,height:30),7), angle:-90)
        }
        text(r.label, x:lx, top:yt+7, size:15.5, color: NSColor(srgbRed:0.10,green:0.07,blue:0.02,alpha:1), weight:.semibold)
    } else {
        text(r.label, x:lx, top:yt+7, size:15.5, color: NSColor(white:0.93,alpha:1))
    }
    if r.kind == 1 {  // checkmark
        symbol("checkmark", x:px+13, top:yt+8, pt:13, color: NSColor(srgbRed:0.93,green:0.66,blue:0.32,alpha:1))
    }
    yt += 36
}

NSGraphicsContext.restoreGraphicsState()
try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: "screenshot.png"))
print("wrote screenshot.png (\(W)x\(H))")
