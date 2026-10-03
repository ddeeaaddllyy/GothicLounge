// Run from the repository root: swift Scripts/GenerateIcon.swift
// Original vector artwork, rendered to the app's 1024 px icon.
import AppKit

let size = 1024
let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
    bitsPerSample: 8, samplesPerPixel: 3, hasAlpha: false, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
let background = NSColor(srgbRed: 0.045, green: 0.049, blue: 0.065, alpha: 1)
let gold = NSColor(srgbRed: 0.79, green: 0.66, blue: 0.43, alpha: 1)
background.setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
let glow = NSGradient(starting: NSColor(srgbRed: 0.19, green: 0.13, blue: 0.22, alpha: 1), ending: background)!
glow.draw(in: NSBezierPath(ovalIn: NSRect(x: 70, y: 70, width: 884, height: 884)), relativeCenterPosition: .zero)
for i in 0..<4 {
    let inset = CGFloat(i) * 40
    let left = 180 + inset
    let right = 844 - inset
    let top = 900 - inset
    let path = NSBezierPath()
    path.move(to: NSPoint(x: left, y: 145))
    path.line(to: NSPoint(x: left, y: 540))
    path.curve(to: NSPoint(x: 512, y: top), controlPoint1: NSPoint(x: left, y: 720), controlPoint2: NSPoint(x: 410, y: top - 50))
    path.curve(to: NSPoint(x: right, y: 540), controlPoint1: NSPoint(x: 614, y: top - 50), controlPoint2: NSPoint(x: right, y: 720))
    path.line(to: NSPoint(x: right, y: 145))
    gold.withAlphaComponent(i == 3 ? 0.85 : 0.2).setStroke()
    path.lineWidth = i == 3 ? 4 : 2
    path.stroke()
}
let moon = NSBezierPath()
moon.move(to: NSPoint(x: 550, y: 646))
moon.curve(to: NSPoint(x: 580, y: 396), controlPoint1: NSPoint(x: 377, y: 706), controlPoint2: NSPoint(x: 333, y: 419))
moon.curve(to: NSPoint(x: 550, y: 646), controlPoint1: NSPoint(x: 425, y: 434), controlPoint2: NSPoint(x: 429, y: 598))
moon.close()
NSGradient(starting: NSColor(srgbRed: 0.95, green: 0.88, blue: 0.72, alpha: 1), ending: gold)!.draw(in: moon, angle: -90)
func star(x: CGFloat, y: CGFloat, radius: CGFloat) {
    let path = NSBezierPath()
    path.move(to: NSPoint(x: x, y: y + radius))
    path.line(to: NSPoint(x: x + radius * 0.23, y: y + radius * 0.23))
    path.line(to: NSPoint(x: x + radius, y: y))
    path.line(to: NSPoint(x: x + radius * 0.23, y: y - radius * 0.23))
    path.line(to: NSPoint(x: x, y: y - radius))
    path.line(to: NSPoint(x: x - radius * 0.23, y: y - radius * 0.23))
    path.line(to: NSPoint(x: x - radius, y: y))
    path.line(to: NSPoint(x: x - radius * 0.23, y: y + radius * 0.23))
    path.close(); gold.setFill(); path.fill()
}
star(x: 590, y: 575, radius: 40)
star(x: 640, y: 665, radius: 17)
star(x: 512, y: 270, radius: 15)
NSGraphicsContext.restoreGraphicsState()
let destination = URL(fileURLWithPath: "GothicLounge/Assets.xcassets/AppIcon.appiconset/NoctisIcon.png")
try bitmap.representation(using: .png, properties: [:])!.write(to: destination)
print("Generated \(destination.lastPathComponent)")
