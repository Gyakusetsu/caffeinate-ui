import ServiceManagement
import SwiftUI

@Observable
final class CaffeinateViewModel {
    var enabledFlags: [CaffeinateFlag: Bool] = [:]
    var selectedTimeout: TimeoutOption = .indefinite {
        didSet {
            guard !isRestoring else { return }
            saveState()
            if isActive { syncProcess() }
        }
    }
    var customTimeoutSeconds: Int = 600 {
        didSet {
            guard !isRestoring else { return }
            saveState()
            if isActive { syncProcess() }
        }
    }
    var remainingSeconds: Int = 0
    private(set) var totalTimeoutSeconds: Int = 0
    private(set) var timeoutStartDate: Date?
    private(set) var timeoutProgress: Double = 0
    private(set) var isActive: Bool = false

    var launchAtLogin: Bool = SMAppService.mainApp.status == .enabled {
        didSet {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Registration can fail if user denies in System Settings;
                // revert to actual state so the toggle stays in sync.
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
    }

    private let service: CaffeinateServiceProtocol
    private let defaults: UserDefaultsProtocol
    private var countdownTimer: Timer?
    private var isRestoring = false

    private enum Keys {
        static let enabledFlags = "enabledFlags"
        static let selectedTimeout = "selectedTimeout"
        static let customTimeoutSeconds = "customTimeoutSeconds"
    }

    var iconName: String {
        isActive ? "cup.and.heat.waves.fill" : "cup.and.heat.waves"
    }

    var activeFlags: [CaffeinateFlag] {
        CaffeinateFlag.allCases.filter { enabledFlags[$0] == true }
    }

    var commandString: String? {
        let flags = activeFlags
        guard !flags.isEmpty else { return nil }
        var parts = ["caffeinate"] + flags.map(\.rawValue)
        if let timeout = resolveTimeout(flags: flags) {
            parts += ["-t", "\(timeout)"]
        }
        return parts.joined(separator: " ")
    }

    init(
        service: CaffeinateServiceProtocol = CaffeinateService(),
        defaults: UserDefaultsProtocol = UserDefaults.standard
    ) {
        self.service = service
        self.defaults = defaults
        service.killAll()

        service.onTermination = { [weak self] in
            self?.isActive = false
            self?.stopCountdown()
            self?.remainingSeconds = 0
            self?.totalTimeoutSeconds = 0
            self?.timeoutStartDate = nil
            self?.timeoutProgress = 0
            self?.enabledFlags = [:]
            self?.saveState()
        }

        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.service.stop()
        }

        restoreState()
        syncProcess()
    }

    func binding(for flag: CaffeinateFlag) -> Binding<Bool> {
        Binding(
            get: { self.enabledFlags[flag] ?? false },
            set: { newValue in
                self.enabledFlags[flag] = newValue
                self.syncProcess()
                self.saveState()
            }
        )
    }

    func toggleAllFlags(_ enabled: Bool) {
        for flag in CaffeinateFlag.allCases {
            enabledFlags[flag] = enabled
        }
        syncProcess()
        saveState()
    }

    func stopAll() {
        service.stop()
        service.killAll()
        isActive = false
        stopCountdown()
        enabledFlags = [:]
        remainingSeconds = 0
        totalTimeoutSeconds = 0
        timeoutStartDate = nil
        timeoutProgress = 0
        saveState()
    }

    // MARK: - Persistence

    private func saveState() {
        let flagKeys = enabledFlags.compactMap { $0.value ? $0.key : nil }
        if let data = try? JSONEncoder().encode(flagKeys) {
            defaults.set(data, forKey: Keys.enabledFlags)
        }
        defaults.set(selectedTimeout.rawValue, forKey: Keys.selectedTimeout)
        defaults.set(customTimeoutSeconds, forKey: Keys.customTimeoutSeconds)
    }

    private func restoreState() {
        isRestoring = true
        defer { isRestoring = false }

        if let data = defaults.data(forKey: Keys.enabledFlags),
           let flags = try? JSONDecoder().decode([CaffeinateFlag].self, from: data) {
            for flag in flags {
                enabledFlags[flag] = true
            }
        }

        if let raw = defaults.string(forKey: Keys.selectedTimeout),
           let timeout = TimeoutOption(rawValue: raw) {
            selectedTimeout = timeout
        }

        let saved = defaults.integer(forKey: Keys.customTimeoutSeconds)
        if saved > 0 {
            customTimeoutSeconds = saved
        }
    }

    // MARK: - Private

    private func syncProcess() {
        let flags = activeFlags
        guard !flags.isEmpty else {
            service.stop()
            isActive = false
            stopCountdown()
            remainingSeconds = 0
            totalTimeoutSeconds = 0
            timeoutStartDate = nil
            timeoutProgress = 0
            return
        }

        let timeout = resolveTimeout(flags: flags)
        service.start(flags: flags, timeout: timeout)
        isActive = true

        if let timeout {
            remainingSeconds = timeout
            totalTimeoutSeconds = timeout
            timeoutStartDate = Date()
            timeoutProgress = 1
            startCountdown()
        } else {
            remainingSeconds = 0
            totalTimeoutSeconds = 0
            timeoutStartDate = nil
            timeoutProgress = 0
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
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            guard let self, let start = self.timeoutStartDate else { return }
            let total = Double(self.totalTimeoutSeconds)
            let elapsed = Date().timeIntervalSince(start)
            let remaining = total - elapsed

            self.timeoutProgress = max(0, min(1, remaining / total))

            let newSeconds = max(0, Int(remaining.rounded(.up)))
            if self.remainingSeconds != newSeconds {
                self.remainingSeconds = newSeconds
            }

            if remaining <= 0 {
                self.stopCountdown()
                self.isActive = false
                self.remainingSeconds = 0
                self.totalTimeoutSeconds = 0
                self.timeoutStartDate = nil
                self.timeoutProgress = 0
                self.enabledFlags = [:]
                self.saveState()
            }
        }
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
