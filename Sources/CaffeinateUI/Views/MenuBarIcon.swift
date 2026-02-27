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

        guard progress > 0 else {
            // No progress — standard template image (adapts to menu bar appearance)
            let image = NSImage(size: imageSize, flipped: false) { rect in
                self.drawSymbol(in: rect, pointSize: 12)
                return true
            }
            image.isTemplate = true
            return image
        }

        // With progress — non-template so the orange ring color is preserved
        let image = NSImage(size: imageSize, flipped: false) { rect in
            // Draw and tint the SF Symbol for the current appearance
            self.drawTintedSymbol(in: rect, pointSize: 10)
            // Draw the colored progress ring on top
            self.drawProgressRing(in: rect)
            return true
        }
        image.isTemplate = false
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

    private func drawTintedSymbol(in rect: NSRect, pointSize: CGFloat) {
        guard let symbol = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: pointSize, weight: .regular)) else { return }

        let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        let tintColor: NSColor = isDark ? .white : .black

        // Create a tinted copy of the symbol so fill(using:) only affects the symbol pixels
        let tinted = NSImage(size: symbol.size, flipped: false) { symbolRect in
            symbol.draw(in: symbolRect)
            tintColor.set()
            symbolRect.fill(using: .sourceAtop)
            return true
        }
        tinted.isTemplate = false

        let tintedSize = tinted.size
        let origin = NSPoint(
            x: (rect.width - tintedSize.width) / 2,
            y: (rect.height - tintedSize.height) / 2
        )
        tinted.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
    }

    private func drawProgressRing(in rect: NSRect) {
        let inset: CGFloat = 1
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
        NSColor.systemOrange.setStroke()
        path.stroke()
    }
}
