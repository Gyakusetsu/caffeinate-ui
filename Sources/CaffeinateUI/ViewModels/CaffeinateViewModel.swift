import SwiftUI

@Observable
final class CaffeinateViewModel {
    var enabledFlags: [CaffeinateFlag: Bool] = [:]
    var selectedTimeout: TimeoutOption = .indefinite
    var customTimeoutMinutes: Int = 10
    var remainingSeconds: Int = 0

    private let service = CaffeinateService()
    private var countdownTimer: Timer?

    var isActive: Bool { service.isRunning }

    var iconName: String {
        service.isRunning ? "cup.and.saucer.fill" : "cup.and.saucer"
    }

    var activeFlags: [CaffeinateFlag] {
        CaffeinateFlag.allCases.filter { enabledFlags[$0] == true }
    }

    init() {
        service.onTermination = { [weak self] in
            self?.handleProcessTerminated()
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
        stopCountdown()
        enabledFlags = [:]
        remainingSeconds = 0
    }

    // MARK: - Private

    private func syncProcess() {
        let flags = activeFlags
        guard !flags.isEmpty else {
            service.stop()
            stopCountdown()
            remainingSeconds = 0
            return
        }

        let timeout = resolveTimeout(flags: flags)
        service.start(flags: flags, timeout: timeout)

        if let timeout {
            remainingSeconds = timeout
            startCountdown()
        } else {
            remainingSeconds = 0
            stopCountdown()
        }
    }

    private func resolveTimeout(flags: [CaffeinateFlag]) -> Int? {
        // -u flag has a default 5s timeout if no explicit timeout is set,
        // so always provide an explicit timeout when -u is active
        let hasUserActive = flags.contains(.declareUserActive)
        let timeout = selectedTimeout.seconds(customMinutes: customTimeoutMinutes)

        if hasUserActive && timeout == nil {
            // -u without timeout defaults to 5s — override with a long duration
            return 8 * 60 * 60 // 8 hours
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

    private func handleProcessTerminated() {
        stopCountdown()
        remainingSeconds = 0
    }
}
