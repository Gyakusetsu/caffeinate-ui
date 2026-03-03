import SwiftUI

struct TimeoutPicker: View {
    @Binding var selectedTimeout: TimeoutOption
    @Binding var customSeconds: Int
    @Binding var scheduledDate: Date

    @State private var hours: Int = 0
    @State private var minutes: Int = 10
    @State private var seconds: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Timeout", selection: $selectedTimeout) {
                ForEach(TimeoutOption.allCases) { option in
                    Text(option.label).tag(option)
                }
            }
            .pickerStyle(.menu)

            if selectedTimeout == .scheduled {
                DatePicker("Until", selection: $scheduledDate,
                    in: Date().addingTimeInterval(60)...,
                    displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }

            if selectedTimeout == .custom {
                HStack(spacing: 4) {
                    TimeUnitField(value: $hours, range: 0...23, label: "h")
                    Text(":")
                        .foregroundStyle(.secondary)
                    TimeUnitField(value: $minutes, range: 0...59, label: "m")
                    Text(":")
                        .foregroundStyle(.secondary)
                    TimeUnitField(value: $seconds, range: 0...59, label: "s")
                }
                .onAppear { decompose(customSeconds) }
                .onChange(of: hours) { _, _ in syncToBinding() }
                .onChange(of: minutes) { _, _ in syncToBinding() }
                .onChange(of: seconds) { _, _ in syncToBinding() }
            }
        }
    }

    private func decompose(_ total: Int) {
        hours = total / 3600
        minutes = (total % 3600) / 60
        seconds = total % 60
    }

    private func syncToBinding() {
        let total = hours * 3600 + minutes * 60 + seconds
        customSeconds = max(total, 1)
    }
}

private struct TimeUnitField: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String

    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 2) {
            TextField("", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(width: 36)
                .multilineTextAlignment(.center)
                .focused($focused)
                .onSubmit { apply() }
                .onChange(of: focused) { _, isFocused in
                    if !isFocused { apply() }
                }
            Text(label)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .onAppear { text = String(format: "%02d", value) }
        .onChange(of: value) { _, newValue in
            text = String(format: "%02d", newValue)
        }
    }

    private func apply() {
        if let parsed = Int(text), range.contains(parsed) {
            value = parsed
        }
        text = String(format: "%02d", value)
    }
}
