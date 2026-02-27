import XCTest
@testable import CaffeinateCore

final class CaffeinateFlagTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(CaffeinateFlag.preventDisplaySleep.rawValue, "-d")
        XCTAssertEqual(CaffeinateFlag.preventIdleSleep.rawValue, "-i")
        XCTAssertEqual(CaffeinateFlag.preventSystemSleep.rawValue, "-s")
        XCTAssertEqual(CaffeinateFlag.declareUserActive.rawValue, "-u")
    }

    func testAllCasesCount() {
        XCTAssertEqual(CaffeinateFlag.allCases.count, 4)
    }

    func testLabelsAreNonEmpty() {
        for flag in CaffeinateFlag.allCases {
            XCTAssertFalse(flag.label.isEmpty, "\(flag) has empty label")
        }
    }

    func testExplanationsAreNonEmpty() {
        for flag in CaffeinateFlag.allCases {
            XCTAssertFalse(flag.explanation.isEmpty, "\(flag) has empty explanation")
        }
    }
}
