import Foundation

enum TimeoutOption: String, Hashable, CaseIterable, Identifiable, Codable {
    case minutes15
    case minutes30
    case hours1
    case hours2
    case hours8
    case hours12
    case custom
    case scheduled
    case indefinite

    var id: Self { self }

    static var allCases: [TimeoutOption] {
        [.minutes15, .minutes30, .hours1, .hours2, .hours8, .hours12, .custom, .scheduled, .indefinite]
    }

    var label: String {
        switch self {
        case .minutes15: "15 minutes"
        case .minutes30: "30 minutes"
        case .hours1: "1 hour"
        case .hours2: "2 hours"
        case .hours8: "8 hours"
        case .hours12: "12 hours"
        case .custom: "Custom"
        case .scheduled: "Scheduled"
        case .indefinite: "Indefinite"
        }
    }

    /// Returns the duration in seconds, or nil for indefinite.
    func seconds(customSeconds: Int, scheduledDate: Date? = nil) -> Int? {
        switch self {
        case .minutes15: return 15 * 60
        case .minutes30: return 30 * 60
        case .hours1: return 60 * 60
        case .hours2: return 2 * 60 * 60
        case .hours8: return 8 * 60 * 60
        case .hours12: return 12 * 60 * 60
        case .custom: return max(customSeconds, 1)
        case .scheduled:
            guard let scheduledDate else { return nil }
            return max(Int(scheduledDate.timeIntervalSinceNow.rounded(.up)), 60)
        case .indefinite: return nil
        }
    }
}
