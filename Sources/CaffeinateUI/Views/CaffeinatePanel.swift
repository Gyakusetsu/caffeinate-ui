import AppKit
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
                Toggle("Enable All", isOn: Binding(
                    get: { CaffeinateFlag.allCases.allSatisfy { self.viewModel.enabledFlags[$0] == true } },
                    set: { viewModel.toggleAllFlags($0) }
                ))
                .toggleStyle(.checkbox)
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
                    customSeconds: $viewModel.customTimeoutSeconds,
                    scheduledDate: $viewModel.scheduledDate
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
                Toggle("Launch at Login", isOn: $viewModel.launchAtLogin)
                .toggleStyle(.checkbox)
                Spacer()
                if viewModel.isActive {
                    Button("Stop All") {
                        viewModel.stopAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }

            Divider()

            HStack {
                HStack(spacing: 4) {
                    Text("Made by Reymar &")
                    Image(systemName: "sparkles")
                    Text("Claude")
                }
                .foregroundStyle(.secondary)

                Spacer()

                VersionLabel(
                    version: viewModel.currentVersion,
                    status: viewModel.updateStatus
                )
            }
            .font(.caption)
        }
        .padding()
        .frame(width: 340)
    }
}

private struct VersionLabel: View {
    let version: String
    let status: UpdateStatus
    @State private var isHovering = false

    var body: some View {
        switch status {
        case .unknown:
            Text("v\(version)")
                .foregroundStyle(.secondary)

        case .upToDate:
            HStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 6, height: 6)
                Text("v\(version)")
                    .foregroundStyle(.secondary)
            }
            .help("Up to date")

        case .updateAvailable(let latestVersion, let url):
            HStack(spacing: 4) {
                Circle()
                    .fill(.orange)
                    .frame(width: 6, height: 6)
                Text("v\(version)")
                    .foregroundStyle(.orange)
            }
            .help("Update available: \(latestVersion)")
            .onTapGesture {
                NSWorkspace.shared.open(url)
            }
            .onHover { hovering in
                isHovering = hovering
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}
