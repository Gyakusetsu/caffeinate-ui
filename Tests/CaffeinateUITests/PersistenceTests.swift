import XCTest
@testable import CaffeinateCore

final class PersistenceTests: XCTestCase {

    // MARK: - Saving state

    func testSavesEnabledFlagsOnToggle() {
        let defaults = MockUserDefaults()
        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        let data = defaults.data(forKey: "enabledFlags")
        XCTAssertNotNil(data)
        let flags = try? JSONDecoder().decode([CaffeinateFlag].self, from: data!)
        XCTAssertEqual(flags, [.preventDisplaySleep])
    }

    func testSavesSelectedTimeoutOnChange() {
        let defaults = MockUserDefaults()
        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        vm.selectedTimeout = .hours2

        XCTAssertEqual(defaults.string(forKey: "selectedTimeout"), "hours2")
    }

    func testSavesCustomTimeoutSecondsOnChange() {
        let defaults = MockUserDefaults()
        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        vm.customTimeoutSeconds = 1234

        XCTAssertEqual(defaults.integer(forKey: "customTimeoutSeconds"), 1234)
    }

    // MARK: - Restoring state

    func testRestoresStateOnInit() {
        let defaults = MockUserDefaults()

        // Pre-populate defaults as if a previous session saved them
        let flagData = try! JSONEncoder().encode([CaffeinateFlag.preventDisplaySleep, .preventIdleSleep])
        defaults.set(flagData, forKey: "enabledFlags")
        defaults.set("hours1", forKey: "selectedTimeout")
        defaults.set(999, forKey: "customTimeoutSeconds")

        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        XCTAssertTrue(vm.enabledFlags[.preventDisplaySleep] == true)
        XCTAssertTrue(vm.enabledFlags[.preventIdleSleep] == true)
        XCTAssertEqual(vm.selectedTimeout, .hours1)
        XCTAssertEqual(vm.customTimeoutSeconds, 999)
    }

    func testRestoredStateResumesCaffeinating() {
        let defaults = MockUserDefaults()
        let flagData = try! JSONEncoder().encode([CaffeinateFlag.preventDisplaySleep])
        defaults.set(flagData, forKey: "enabledFlags")

        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        XCTAssertTrue(vm.isActive)
        XCTAssertEqual(mock.startCallCount, 1)
        XCTAssertEqual(mock.lastStartFlags, [.preventDisplaySleep])
    }

    // MARK: - stopAll clears persisted flags

    func testStopAllClearsPersistedFlags() {
        let defaults = MockUserDefaults()
        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        vm.stopAll()

        let data = defaults.data(forKey: "enabledFlags")
        XCTAssertNotNil(data)
        let flags = try? JSONDecoder().decode([CaffeinateFlag].self, from: data!)
        XCTAssertEqual(flags, [])
    }

    // MARK: - Scheduled date persistence

    func testSavesScheduledDateOnChange() {
        let defaults = MockUserDefaults()
        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        let futureDate = Date().addingTimeInterval(7200)
        vm.scheduledDate = futureDate

        let saved = defaults.double(forKey: "scheduledDate")
        XCTAssertEqual(saved, futureDate.timeIntervalSince1970, accuracy: 0.001)
    }

    func testRestoresScheduledDateOnInit() {
        let defaults = MockUserDefaults()
        let futureDate = Date().addingTimeInterval(7200)
        defaults.set(futureDate.timeIntervalSince1970, forKey: "scheduledDate")

        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        XCTAssertEqual(vm.scheduledDate.timeIntervalSince1970, futureDate.timeIntervalSince1970, accuracy: 0.001)
    }

    // MARK: - Corrupted defaults

    func testHandlesCorruptedFlagDataGracefully() {
        let defaults = MockUserDefaults()
        defaults.set("not valid json".data(using: .utf8), forKey: "enabledFlags")
        defaults.set("notAValidTimeout", forKey: "selectedTimeout")
        defaults.set(0, forKey: "customTimeoutSeconds")

        let mock = MockCaffeinateService()
        let vm = CaffeinateViewModel(service: mock, defaults: defaults, updateChecker: MockUpdateCheckerService())

        // Falls back to defaults
        XCTAssertTrue(vm.activeFlags.isEmpty)
        XCTAssertEqual(vm.selectedTimeout, .indefinite)
        XCTAssertEqual(vm.customTimeoutSeconds, 600)
    }
}
