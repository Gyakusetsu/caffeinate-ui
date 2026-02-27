import SwiftUI

struct CaffeinatePanel: View {
    @Bindable var viewModel: CaffeinateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: viewModel.iconName)
                    .font(.title2)
                    .foregroundStyle(viewModel.isActive ? .orange : .secondary)
                Text("Caffeinate")
                    .font(.headline)
                Spacer()
            }

            Divider()

            // Flag toggles
            ForEach(CaffeinateFlag.allCases) { flag in
                FlagToggleRow(
                    flag: flag,
                    isOn: viewModel.binding(for: flag)
                )
            }

            Divider()

            // Timeout picker + remaining time
            HStack {
                TimeoutPicker(
                    selectedTimeout: $viewModel.selectedTimeout,
                    customSeconds: $viewModel.customTimeoutSeconds
                )
                Spacer()
                if viewModel.isActive, viewModel.remainingSeconds > 0 {
                    TimerDisplay(remainingSeconds: viewModel.remainingSeconds)
                }
            }

            // Command display
            if let command = viewModel.commandString {
                Divider()
                Text(command)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }

            Divider()

            // Actions
            HStack {
                if viewModel.isActive {
                    Button("Stop All") {
                        viewModel.stopAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                Spacer()
                Button("Quit") {
                    viewModel.stopAll()
                    NSApp.terminate(nil)
                }
            }

            Divider()

            HStack(spacing: 4) {
                Text("Made by Reymar &")
                Image(systemName: "sparkles")
                Text("Claude")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(width: 340)
    }
}
