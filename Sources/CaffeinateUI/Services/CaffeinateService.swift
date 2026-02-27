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

        process.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.process = nil
                self?.onTermination?()
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
