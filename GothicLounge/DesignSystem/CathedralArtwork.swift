import SwiftUI

struct PointedArch: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.46))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.16))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.46), control: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.16))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return p
    }
}

struct CathedralArtwork: View {
    @Environment(\.gothicPalette) private var palette
    var animated = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: reduceMotion || !animated || scenePhase != .active)) { timeline in
            let time = reduceMotion || !animated ? 0 : timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height * 0.43)
                let glow = CGRect(x: center.x - 105, y: center.y - 95, width: 210, height: 210)
                context.fill(Path(ellipseIn: glow), with: .radialGradient(Gradient(colors: [palette.plum.opacity(0.28), .clear]), center: center, startRadius: 0, endRadius: 110))
                for i in 0..<5 {
                    let width = CGFloat(120 + i * 35)
                    let rect = CGRect(x: center.x - width / 2, y: CGFloat(20 - i * 6), width: width, height: size.height + 40)
                    context.stroke(PointedArch().path(in: rect), with: .color(palette.gold.opacity(i == 0 ? 0.5 : 0.12)), lineWidth: i == 0 ? 1.2 : 0.7)
                }
                let moon = CGRect(x: center.x - 27, y: center.y - 27, width: 54, height: 54)
                context.fill(Path(ellipseIn: moon), with: .linearGradient(Gradient(colors: [palette.ivory, palette.gold]), startPoint: CGPoint(x: center.x - 20, y: center.y - 25), endPoint: CGPoint(x: center.x + 30, y: center.y + 30)))
                context.fill(Path(ellipseIn: moon.offsetBy(dx: 17, dy: -9)), with: .color(palette.surface))
                for i in 0..<22 {
                    let x = CGFloat((i * 71 + 31) % 311) / 311 * size.width
                    let y = (CGFloat(i * 43) + CGFloat(time.truncatingRemainder(dividingBy: 40)) * CGFloat(2 + i % 3)).truncatingRemainder(dividingBy: max(size.height, 1))
                    let opacity = 0.15 + 0.35 * (sin(time * 0.7 + Double(i)) + 1) / 2
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: i % 3 == 0 ? 2 : 1, height: i % 3 == 0 ? 2 : 1)), with: .color(palette.gold.opacity(opacity)))
                }
                for i in 0..<7 {
                    let angle = Double(i) * .pi / 3.5
                    let a = CGPoint(x: center.x + cos(angle) * 47, y: center.y + sin(angle) * 47)
                    let b = CGPoint(x: center.x + cos(angle) * 52, y: center.y + sin(angle) * 52)
                    var ray = Path(); ray.move(to: a); ray.addLine(to: b)
                    context.stroke(ray, with: .color(palette.gold.opacity(0.65)), lineWidth: 1)
                }
            }
        }.clipped().accessibilityHidden(true)
    }
}
