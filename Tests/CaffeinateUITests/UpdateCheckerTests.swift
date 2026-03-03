import XCTest
@testable import CaffeinateCore

// MARK: - SemanticVersion Tests

final class SemanticVersionTests: XCTestCase {

    func testParsesTwoComponents() {
        let v = SemanticVersion(string: "1.2")
        XCTAssertEqual(v?.major, 1)
        XCTAssertEqual(v?.minor, 2)
        XCTAssertEqual(v?.patch, 0)
    }

    func testParsesThreeComponents() {
        let v = SemanticVersion(string: "2.3.4")
        XCTAssertEqual(v?.major, 2)
        XCTAssertEqual(v?.minor, 3)
        XCTAssertEqual(v?.patch, 4)
    }

    func testStripsVPrefix() {
        let v = SemanticVersion(string: "v1.5")
        XCTAssertEqual(v?.major, 1)
        XCTAssertEqual(v?.minor, 5)
    }

    func testStripsVPrefixThreeComponents() {
        let v = SemanticVersion(string: "v3.2.1")
        XCTAssertEqual(v?.major, 3)
        XCTAssertEqual(v?.minor, 2)
        XCTAssertEqual(v?.patch, 1)
    }

    func testSingleComponentReturnsNil() {
        XCTAssertNil(SemanticVersion(string: "1"))
    }

    func testEmptyStringReturnsNil() {
        XCTAssertNil(SemanticVersion(string: ""))
    }

    func testGarbageReturnsNil() {
        XCTAssertNil(SemanticVersion(string: "not-a-version"))
    }

    func testCompareMajor() {
        let v1 = SemanticVersion(string: "1.0.0")!
        let v2 = SemanticVersion(string: "2.0.0")!
        XCTAssertTrue(v1 < v2)
        XCTAssertFalse(v2 < v1)
    }

    func testCompareMinor() {
        let v1 = SemanticVersion(string: "1.2.0")!
        let v2 = SemanticVersion(string: "1.3.0")!
        XCTAssertTrue(v1 < v2)
    }

    func testComparePatch() {
        let v1 = SemanticVersion(string: "1.2.3")!
        let v2 = SemanticVersion(string: "1.2.4")!
        XCTAssertTrue(v1 < v2)
    }

    func testEqual() {
        let v1 = SemanticVersion(string: "1.2.0")!
        let v2 = SemanticVersion(string: "v1.2")!
        XCTAssertEqual(v1, v2)
        XCTAssertFalse(v1 < v2)
        XCTAssertFalse(v2 < v1)
    }

    func testNewerCurrentNotLessThan() {
        let current = SemanticVersion(string: "2.0.0")!
        let latest = SemanticVersion(string: "1.5.0")!
        XCTAssertFalse(current < latest)
    }
}

// MARK: - UpdateStatus ViewModel Tests

final class UpdateStatusViewModelTests: XCTestCase {

    func testDefaultStatusIsUnknown() {
        let mock = MockCaffeinateService()
        let updateMock = MockUpdateCheckerService()
        let vm = CaffeinateViewModel(service: mock, defaults: MockUserDefaults(), updateChecker: updateMock)
        XCTAssertEqual(vm.updateStatus, .unknown)
    }

    func testCheckForUpdateReflectsUpToDate() async {
        let mock = MockCaffeinateService()
        let updateMock = MockUpdateCheckerService()
        updateMock.stubbedStatus = .upToDate
        let vm = CaffeinateViewModel(service: mock, defaults: MockUserDefaults(), updateChecker: updateMock)

        await vm.checkForUpdate()

        XCTAssertEqual(vm.updateStatus, .upToDate)
        XCTAssertTrue(updateMock.checkCallCount >= 1)
    }

    func testCheckForUpdateReflectsUpdateAvailable() async {
        let mock = MockCaffeinateService()
        let updateMock = MockUpdateCheckerService()
        let url = URL(string: "https://github.com/Gyakusetsu/caffeinate-ui/releases/tag/v2.0")!
        updateMock.stubbedStatus = .updateAvailable(latestVersion: "v2.0", url: url)
        let vm = CaffeinateViewModel(service: mock, defaults: MockUserDefaults(), updateChecker: updateMock)

        await vm.checkForUpdate()

        XCTAssertEqual(vm.updateStatus, .updateAvailable(latestVersion: "v2.0", url: url))
    }
}
