import SwiftUI

public struct CaffeinateUIApp: App {
    @State private var viewModel = CaffeinateViewModel()

    public init() {
        SingleInstance.acquire()
    }

    public var body: some Scene {
        MenuBarExtra {
            CaffeinatePanel(viewModel: viewModel)
        } label: {
            MenuBarIcon(iconName: viewModel.iconName, progress: viewModel.timeoutProgress)
        }
        .menuBarExtraStyle(.window)
    }
}

/// Ensures only one instance of the app runs at a time using a POSIX file lock.
/// The lock is held for the lifetime of the process and auto-releases on exit or crash.
enum SingleInstance {
    private static let lockPath = "/tmp/caffeinate-ui.lock"
    private static var fd: Int32 = -1

    static func acquire() {
        fd = open(lockPath, O_CREAT | O_RDWR, 0o644)
        guard fd >= 0 else {
            NSLog("Caffeinate UI: failed to open lock file")
            exit(1)
        }
        if flock(fd, LOCK_EX | LOCK_NB) != 0 {
            NSLog("Caffeinate UI: another instance is already running")
            exit(0)
        }
    }
}
