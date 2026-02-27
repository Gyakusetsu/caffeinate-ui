import SwiftUI

struct MenuBarIcon: View {
    let iconName: String
    let progress: Double

    var body: some View {
        Image(nsImage: createMenuBarImage())
    }

    private func createMenuBarImage() -> NSImage {
        let size: CGFloat = 24
        let imageSize = NSSize(width: size, height: size)

        let image = NSImage(size: imageSize, flipped: false) { rect in
            if self.progress > 0 {
                // Draw outline cup as base, then overlay filled cup clipped to progress
                let outlineName = self.iconName.replacingOccurrences(of: ".fill", with: "")
                self.drawSymbol(outlineName, in: rect)

                NSGraphicsContext.saveGraphicsState()
                let clipHeight = (rect.height - 2) * CGFloat(self.progress)
                NSBezierPath(rect: NSRect(x: 0, y: 0, width: rect.width, height: clipHeight)).setClip()
                self.drawSymbol(self.iconName, in: rect)
                NSGraphicsContext.restoreGraphicsState()
            } else {
                self.drawSymbol(self.iconName, in: rect)
            }
            return true
        }
        image.isTemplate = true
        return image
    }

    private func drawSymbol(_ name: String, in rect: NSRect) {
        guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(.init(pointSize: 17, weight: .regular)) else { return }
        let symbolSize = symbol.size
        let origin = NSPoint(
            x: (rect.width - symbolSize.width) / 2,
            y: (rect.height - symbolSize.height) / 2
        )
        symbol.draw(at: origin, from: .zero, operation: .sourceOver, fraction: 1)
    }
}
