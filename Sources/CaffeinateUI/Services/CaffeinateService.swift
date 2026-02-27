import Foundation

protocol CaffeinateServiceProtocol: AnyObject {
    var onTermination: (() -> Void)? { get set }
    func start(flags: [CaffeinateFlag], timeout: Int?)
    func killAll()
    func stop()
}

final class CaffeinateService: CaffeinateServiceProtocol {
    private var process: Process?
    var onTermination: (() -> Void)?

    var isRunning: Bool {
        process?.isRunning ?? false
    }

    func start(flags: [CaffeinateFlag], timeout: Int?) {
        stop()
        killAll()

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")

        var arguments = flags.map(\.rawValue)
        if let timeout {
            arguments.append("-t")
            arguments.append(String(timeout))
        }
        process.arguments = arguments

        process.terminationHandler = { [weak self] terminated in
            DispatchQueue.main.async {
                // Only handle if this is still the current process,
                // not a stale one from a previous kill-and-respawn
                guard let self, self.process === terminated else { return }
                self.process = nil
                self.onTermination?()
            }
        }

        do {
            try process.run()
            self.process = process
        } catch {
            self.process = nil
        }
    }

    /// Kill all caffeinate processes system-wide so this app is the sole owner.
    func killAll() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        task.arguments = ["-x", "caffeinate"]
        try? task.run()
        task.waitUntilExit()
    }

    func stop() {
        guard let process, process.isRunning else {
            self.process = nil
            return
        }
        process.terminate()
        // Don't call waitUntilExit() — it pumps the run loop, which allows
        // re-entrant syncProcess() calls and spawns duplicate processes.
        self.process = nil
    }
}
