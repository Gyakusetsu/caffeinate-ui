import SwiftUI

struct TimerDisplay: View {
    let remainingSeconds: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundStyle(.orange)
            Text(formatted)
                .monospacedDigit()
                .foregroundStyle(.orange)
                .font(.body)
        }
    }

    private var formatted: String {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
}
