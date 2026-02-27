import XCTest
@testable import CaffeinateCore

final class CaffeinateViewModelTests: XCTestCase {
    private var mock: MockCaffeinateService!
    private var vm: CaffeinateViewModel!

    override func setUp() {
        super.setUp()
        mock = MockCaffeinateService()
        vm = CaffeinateViewModel(service: mock, defaults: MockUserDefaults())
    }

    // MARK: - activeFlags

    func testActiveFlagsFiltersCorrectly() {
        vm.enabledFlags = [.preventDisplaySleep: true, .preventIdleSleep: false, .declareUserActive: true]
        XCTAssertEqual(Set(vm.activeFlags), Set([.preventDisplaySleep, .declareUserActive]))
    }

    func testActiveFlagsEmptyByDefault() {
        XCTAssertTrue(vm.activeFlags.isEmpty)
    }

    // MARK: - commandString

    func testCommandStringWithSingleFlag() {
        vm.enabledFlags = [.preventDisplaySleep: true]
        XCTAssertEqual(vm.commandString, "caffeinate -d")
    }

    func testCommandStringWithTimeout() {
        vm.enabledFlags = [.preventIdleSleep: true]
        vm.selectedTimeout = .minutes15
        XCTAssertEqual(vm.commandString, "caffeinate -i -t 900")
    }

    func testCommandStringWithMultipleFlagsAndTimeout() {
        vm.enabledFlags = [.preventDisplaySleep: true, .preventSystemSleep: true]
        vm.selectedTimeout = .hours1
        XCTAssertEqual(vm.commandString, "caffeinate -d -s -t 3600")
    }

    func testCommandStringNilWhenNoFlags() {
        XCTAssertNil(vm.commandString)
    }

    func testCommandStringIndefiniteHasNoTimeout() {
        vm.enabledFlags = [.preventDisplaySleep: true]
        vm.selectedTimeout = .indefinite
        XCTAssertEqual(vm.commandString, "caffeinate -d")
    }

    func testCommandStringDeclareUserActiveIndefiniteShows8HourTimeout() {
        vm.enabledFlags = [.declareUserActive: true]
        vm.selectedTimeout = .indefinite
        XCTAssertEqual(vm.commandString, "caffeinate -u -t 28800")
    }

    func testCommandStringCustomTimeout() {
        vm.enabledFlags = [.preventIdleSleep: true]
        vm.selectedTimeout = .custom
        vm.customTimeoutSeconds = 300
        XCTAssertEqual(vm.commandString, "caffeinate -i -t 300")
    }

    // MARK: - iconName

    func testIconNameInactive() {
        XCTAssertEqual(vm.iconName, "cup.and.heat.waves")
    }

    // MARK: - stopAll

    func testStopAllResetsState() {
        vm.enabledFlags = [.preventDisplaySleep: true]
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        vm.stopAll()

        XCTAssertFalse(vm.isActive)
        XCTAssertTrue(vm.enabledFlags.isEmpty)
        XCTAssertEqual(vm.remainingSeconds, 0)
        XCTAssertTrue(mock.stopCallCount > 0)
    }

    // MARK: - -u + indefinite override

    func testDeclareUserActiveIndefiniteApplies8HourOverride() {
        let binding = vm.binding(for: .declareUserActive)
        binding.wrappedValue = true

        XCTAssertEqual(mock.lastStartTimeout, 8 * 60 * 60)
        XCTAssertEqual(mock.lastStartFlags, [.declareUserActive])
    }

    func testDeclareUserActiveWithExplicitTimeoutUsesUserTimeout() {
        vm.selectedTimeout = .hours1
        let binding = vm.binding(for: .declareUserActive)
        binding.wrappedValue = true

        XCTAssertEqual(mock.lastStartTimeout, 3600)
    }

    // MARK: - Flag toggle triggers service

    func testTogglingFlagCallsServiceStart() {
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        XCTAssertEqual(mock.startCallCount, 1)
        XCTAssertEqual(mock.lastStartFlags, [.preventDisplaySleep])
    }

    func testTogglingFlagSetsIsActiveTrue() {
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        XCTAssertTrue(vm.isActive, "isActive should be true after toggling a flag on")
    }

    func testDisablingAllFlagsCallsStop() {
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true
        XCTAssertTrue(vm.isActive)

        binding.wrappedValue = false
        XCTAssertFalse(vm.isActive)
        XCTAssertTrue(mock.stopCallCount > 0)
    }

    // MARK: - Timeout change while active

    func testChangingTimeoutWhileActiveResyncs() {
        let binding = vm.binding(for: .preventIdleSleep)
        binding.wrappedValue = true
        let callsBefore = mock.startCallCount

        vm.selectedTimeout = .hours2

        XCTAssertEqual(mock.startCallCount, callsBefore + 1)
        XCTAssertEqual(mock.lastStartTimeout, 7200)
    }

    func testChangingCustomSecondsWhileActiveResyncs() {
        vm.selectedTimeout = .custom
        let binding = vm.binding(for: .preventIdleSleep)
        binding.wrappedValue = true
        let callsBefore = mock.startCallCount

        vm.customTimeoutSeconds = 999

        XCTAssertEqual(mock.startCallCount, callsBefore + 1)
        XCTAssertEqual(mock.lastStartTimeout, 999)
    }

    // MARK: - Termination callback

    func testTerminationCallbackResetsIsActive() {
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true
        XCTAssertTrue(vm.isActive)

        mock.onTermination?()
        XCTAssertFalse(vm.isActive)
        XCTAssertEqual(vm.remainingSeconds, 0)
    }

    func testTerminationCallbackClearsEnabledFlags() {
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true
        XCTAssertTrue(vm.enabledFlags[.preventDisplaySleep] == true)

        mock.onTermination?()
        XCTAssertTrue(vm.enabledFlags.isEmpty)
    }

    // MARK: - timeoutProgress

    func testTimeoutProgressWithActiveTimed() {
        vm.selectedTimeout = .minutes15
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        XCTAssertEqual(vm.totalTimeoutSeconds, 900)
        XCTAssertEqual(vm.timeoutProgress, 1.0, accuracy: 0.01)
    }

    func testTimeoutProgressZeroWhenIndefinite() {
        vm.selectedTimeout = .indefinite
        let binding = vm.binding(for: .preventDisplaySleep)
        binding.wrappedValue = true

        XCTAssertEqual(vm.timeoutProgress, 0)
    }

    func testTimeoutProgressNonZeroWhenDeclareUserActiveIndefinite() {
        vm.selectedTimeout = .indefinite
        let binding = vm.binding(for: .declareUserActive)
        binding.wrappedValue = true

        XCTAssertEqual(vm.totalTimeoutSeconds, 8 * 60 * 60)
        XCTAssertEqual(vm.timeoutProgress, 1.0, accuracy: 0.01)
    }

    func testTimeoutProgressZeroWhenInactive() {
        XCTAssertEqual(vm.timeoutProgress, 0)
    }

    // MARK: - Master toggle

    func testToggleAllFlagsEnablesAll() {
        vm.toggleAllFlags(true)

        for flag in CaffeinateFlag.allCases {
            XCTAssertTrue(vm.enabledFlags[flag] == true)
        }
        XCTAssertTrue(vm.isActive)
    }

    func testToggleAllFlagsDisablesAll() {
        vm.toggleAllFlags(true)
        vm.toggleAllFlags(false)

        for flag in CaffeinateFlag.allCases {
            XCTAssertTrue(vm.enabledFlags[flag] == false)
        }
        XCTAssertFalse(vm.isActive)
    }
}
