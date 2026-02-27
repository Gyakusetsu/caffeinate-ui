import Foundation

final class CaffeinateService {
    private var process: Process?
    var onTermination: (() -> Void)?

    var isRunning: Bool {
        process?.isRunning ?? false
    }

    func start(flags: [CaffeinateFlag], timeout: Int?) {
        stop()

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

    func stop() {
        guard let process, process.isRunning else {
            self.process = nil
            return
        }
        process.terminate()
        process.waitUntilExit()
        self.process = nil
    }
}
