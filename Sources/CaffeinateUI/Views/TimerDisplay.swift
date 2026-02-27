import SwiftUI

func formatDuration(_ totalSeconds: Int) -> String {
    let h = totalSeconds / 3600
    let m = (totalSeconds % 3600) / 60
    let s = totalSeconds % 60
    if h > 0 {
        return String(format: "%d:%02d:%02d", h, m, s)
    }
    return String(format: "%d:%02d", m, s)
}

struct TimerDisplay: View {
    let remainingSeconds: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundStyle(.orange)
            Text(formatDuration(remainingSeconds))
                .monospacedDigit()
                .foregroundStyle(.orange)
                .font(.body)
        }
    }
}
