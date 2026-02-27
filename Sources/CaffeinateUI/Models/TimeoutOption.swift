enum TimeoutOption: Hashable, CaseIterable, Identifiable {
    case minutes15
    case minutes30
    case hours1
    case hours2
    case custom
    case indefinite

    var id: Self { self }

    static var allCases: [TimeoutOption] {
        [.minutes15, .minutes30, .hours1, .hours2, .custom, .indefinite]
    }

    var label: String {
        switch self {
        case .minutes15: "15 minutes"
        case .minutes30: "30 minutes"
        case .hours1: "1 hour"
        case .hours2: "2 hours"
        case .custom: "Custom"
        case .indefinite: "Indefinite"
        }
    }

    /// Returns the duration in seconds, or nil for indefinite.
    func seconds(customMinutes: Int) -> Int? {
        switch self {
        case .minutes15: 15 * 60
        case .minutes30: 30 * 60
        case .hours1: 60 * 60
        case .hours2: 2 * 60 * 60
        case .custom: customMinutes * 60
        case .indefinite: nil
        }
    }
}
