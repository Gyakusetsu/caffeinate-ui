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

            // Timeout picker
            TimeoutPicker(
                selectedTimeout: $viewModel.selectedTimeout,
                customMinutes: $viewModel.customTimeoutMinutes
            )

            // Timer display
            if viewModel.isActive, viewModel.remainingSeconds > 0 {
                TimerDisplay(remainingSeconds: viewModel.remainingSeconds)
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
        }
        .padding()
        .frame(width: 280)
    }
}
