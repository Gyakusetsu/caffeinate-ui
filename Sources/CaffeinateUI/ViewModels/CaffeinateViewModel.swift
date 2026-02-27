import SwiftUI

@Observable
final class CaffeinateViewModel {
    var enabledFlags: [CaffeinateFlag: Bool] = [:]
    var selectedTimeout: TimeoutOption = .indefinite { didSet { if isActive { syncProcess() } } }
    var customTimeoutSeconds: Int = 600 { didSet { if isActive { syncProcess() } } }
    var remainingSeconds: Int = 0
    private(set) var isActive: Bool = false

    private let service = CaffeinateService()
    private var countdownTimer: Timer?

    var iconName: String {
        isActive ? "cup.and.saucer.fill" : "cup.and.saucer"
    }

    var activeFlags: [CaffeinateFlag] {
        CaffeinateFlag.allCases.filter { enabledFlags[$0] == true }
    }

    var commandString: String? {
        let flags = activeFlags
        guard !flags.isEmpty else { return nil }
        var parts = ["caffeinate"] + flags.map(\.rawValue)
        if let timeout = selectedTimeout.seconds(customSeconds: customTimeoutSeconds) {
            parts += ["-t", "\(timeout)"]
        }
        return parts.joined(separator: " ")
    }

    init() {
        killStaleProcesses()

        service.onTermination = { [weak self] in
            self?.isActive = false
            self?.stopCountdown()
            self?.remainingSeconds = 0
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.service.stop()
        }
    }

    func binding(for flag: CaffeinateFlag) -> Binding<Bool> {
        Binding(
            get: { self.enabledFlags[flag] ?? false },
            set: { newValue in
                self.enabledFlags[flag] = newValue
                self.syncProcess()
            }
        )
    }

    func stopAll() {
        service.stop()
        isActive = false
        stopCountdown()
        enabledFlags = [:]
        remainingSeconds = 0
    }

    // MARK: - Private

    private func syncProcess() {
        let flags = activeFlags
        guard !flags.isEmpty else {
            service.stop()
            isActive = false
            stopCountdown()
            remainingSeconds = 0
            return
        }

        let timeout = resolveTimeout(flags: flags)
        service.start(flags: flags, timeout: timeout)
        isActive = true

        // Only show countdown for user-chosen timeouts, not the internal -u override
        let userTimeout = selectedTimeout.seconds(customSeconds: customTimeoutSeconds)
        if let userTimeout {
            remainingSeconds = userTimeout
            startCountdown()
        } else {
            remainingSeconds = 0
            stopCountdown()
        }
    }

    private func resolveTimeout(flags: [CaffeinateFlag]) -> Int? {
        let hasUserActive = flags.contains(.declareUserActive)
        let timeout = selectedTimeout.seconds(customSeconds: customTimeoutSeconds)

        if hasUserActive && timeout == nil {
            return 8 * 60 * 60
        }
        return timeout
    }

    private func startCountdown() {
        stopCountdown()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remainingSeconds > 0 {
                self.remainingSeconds -= 1
            } else {
                self.stopCountdown()
            }
        }
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    /// Kill any caffeinate processes left over from previous sessions
    private func killStaleProcesses() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        task.arguments = ["-x", "caffeinate"]
        try? task.run()
        task.waitUntilExit()
    }
}
