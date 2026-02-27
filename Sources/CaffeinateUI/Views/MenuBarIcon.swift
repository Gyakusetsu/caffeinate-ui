import SwiftUI

struct MenuBarIcon: View {
    let iconName: String
    let progress: Double

    var body: some View {
        Image(nsImage: createMenuBarImage())
    }

    private func createMenuBarImage() -> NSImage {
        let size: CGFloat = 18
        let imageSize = NSSize(width: size, height: size)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            let iconSize: CGFloat = self.progress > 0 ? 9 : 12
            self.drawSymbol(in: rect, pointSize: iconSize)

            if self.progress > 0 {
                self.drawProgressRing(in: rect)
            }

            return true
        }
        image.isTemplate = true
        return image
    }

    private func drawSymbol(in rect: NSRect, pointSize: CGFloat) {
        guard let symbol = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: pointSize, weight: .regular)) else { return }
        let symbolSize = symbol.size
        let origin = NSPoint(
            x: (rect.width - symbolSize.width) / 2,
            y: (rect.height - symbolSize.height) / 2
        )
        symbol.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
    }

    private func drawProgressRing(in rect: NSRect) {
        let inset: CGFloat = 0.75
        let ringRect = rect.insetBy(dx: inset, dy: inset)
        let path = NSBezierPath()
        path.appendArc(
            withCenter: NSPoint(x: ringRect.midX, y: ringRect.midY),
            radius: min(ringRect.width, ringRect.height) / 2,
            startAngle: 90,
            endAngle: 90 - 360 * CGFloat(progress),
            clockwise: true
        )
        path.lineWidth = 1.5
        path.lineCapStyle = .round
        NSColor.black.setStroke()
        path.stroke()
    }
}
