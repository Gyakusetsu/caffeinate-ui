import SwiftUI

struct TimeoutPicker: View {
    @Binding var selectedTimeout: TimeoutOption
    @Binding var customMinutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Timeout", selection: $selectedTimeout) {
                ForEach(TimeoutOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.menu)

            if selectedTimeout == .custom {
                Stepper(
                    "\(customMinutes) min",
                    value: $customMinutes,
                    in: 1...480,
                    step: 5
                )
                .font(.caption)
            }
        }
    }
}
