import SwiftUI

struct MenuBarIcon: View {
    let iconName: String
    let progress: Double

    var body: some View {
        ZStack {
            Image(systemName: iconName)
                .font(.system(size: 12))

            if progress > 0 {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.orange, lineWidth: 1.5)
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: 18, height: 18)
    }
}
