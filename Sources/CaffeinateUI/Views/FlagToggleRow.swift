import SwiftUI

struct FlagToggleRow: View {
    let flag: CaffeinateFlag
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(flag.label)
                    .font(.body)
                Text(flag.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .toggleStyle(.switch)
        .controlSize(.small)
    }
}
