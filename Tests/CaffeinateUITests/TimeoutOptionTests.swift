import XCTest
@testable import CaffeinateCore

final class TimeoutOptionTests: XCTestCase {
    func testSecondsValues() {
        XCTAssertEqual(TimeoutOption.minutes15.seconds(customSeconds: 0), 900)
        XCTAssertEqual(TimeoutOption.minutes30.seconds(customSeconds: 0), 1800)
        XCTAssertEqual(TimeoutOption.hours1.seconds(customSeconds: 0), 3600)
        XCTAssertEqual(TimeoutOption.hours2.seconds(customSeconds: 0), 7200)
        XCTAssertNil(TimeoutOption.indefinite.seconds(customSeconds: 0))
    }

    func testCustomReturnsCustomSeconds() {
        XCTAssertEqual(TimeoutOption.custom.seconds(customSeconds: 420), 420)
    }

    func testCustomClampsZeroToOne() {
        XCTAssertEqual(TimeoutOption.custom.seconds(customSeconds: 0), 1)
    }

    func testCustomClampsNegativeToOne() {
        XCTAssertEqual(TimeoutOption.custom.seconds(customSeconds: -10), 1)
    }

    func testAllCasesOrder() {
        let expected: [TimeoutOption] = [.minutes15, .minutes30, .hours1, .hours2, .custom, .indefinite]
        XCTAssertEqual(TimeoutOption.allCases, expected)
    }

    func testAllCasesCount() {
        XCTAssertEqual(TimeoutOption.allCases.count, 6)
    }
}
