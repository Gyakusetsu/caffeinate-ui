enum CaffeinateFlag: String, CaseIterable, Identifiable, Codable {
    case preventDisplaySleep = "-d"
    case preventIdleSleep = "-i"
    case preventSystemSleep = "-s"
    case declareUserActive = "-u"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .preventDisplaySleep: "Prevent Display Sleep"
        case .preventIdleSleep: "Prevent Idle Sleep"
        case .preventSystemSleep: "Prevent System Sleep"
        case .declareUserActive: "Declare User Active"
        }
    }

    var explanation: String {
        switch self {
        case .preventDisplaySleep: "Keeps the display awake"
        case .preventIdleSleep: "Prevents idle sleep (default caffeinate behavior)"
        case .preventSystemSleep: "Prevents system sleep (AC power only)"
        case .declareUserActive: "Simulates user activity to reset idle timer"
        }
    }
}
