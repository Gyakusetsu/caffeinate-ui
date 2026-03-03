import Foundation
@testable import CaffeinateCore

final class MockCaffeinateService: CaffeinateServiceProtocol {
    var onTermination: (() -> Void)?

    var startCallCount = 0
    var lastStartFlags: [CaffeinateFlag] = []
    var lastStartTimeout: Int?

    var stopCallCount = 0
    var killAllCallCount = 0

    func start(flags: [CaffeinateFlag], timeout: Int?) {
        startCallCount += 1
        lastStartFlags = flags
        lastStartTimeout = timeout
    }

    func stop() {
        stopCallCount += 1
    }

    func killAll() {
        killAllCallCount += 1
    }
}

final class MockUserDefaults: UserDefaultsProtocol {
    private var store: [String: Any] = [:]

    func data(forKey key: String) -> Data? {
        store[key] as? Data
    }

    func string(forKey key: String) -> String? {
        store[key] as? String
    }

    func integer(forKey key: String) -> Int {
        store[key] as? Int ?? 0
    }

    func set(_ value: Any?, forKey key: String) {
        store[key] = value
    }

    func set(_ value: Int, forKey key: String) {
        store[key] = value
    }

    func double(forKey key: String) -> Double {
        store[key] as? Double ?? 0
    }

    func set(_ value: Double, forKey key: String) {
        store[key] = value
    }
}
