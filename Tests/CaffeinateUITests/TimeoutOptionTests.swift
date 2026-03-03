import XCTest
@testable import CaffeinateCore

final class TimeoutOptionTests: XCTestCase {
    func testSecondsValues() {
        XCTAssertEqual(TimeoutOption.minutes15.seconds(customSeconds: 0), 900)
        XCTAssertEqual(TimeoutOption.minutes30.seconds(customSeconds: 0), 1800)
        XCTAssertEqual(TimeoutOption.hours1.seconds(customSeconds: 0), 3600)
        XCTAssertEqual(TimeoutOption.hours2.seconds(customSeconds: 0), 7200)
        XCTAssertEqual(TimeoutOption.hours8.seconds(customSeconds: 0), 28800)
        XCTAssertEqual(TimeoutOption.hours12.seconds(customSeconds: 0), 43200)
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
        let expected: [TimeoutOption] = [.minutes15, .minutes30, .hours1, .hours2, .hours8, .hours12, .custom, .scheduled, .indefinite]
        XCTAssertEqual(TimeoutOption.allCases, expected)
    }

    func testAllCasesCount() {
        XCTAssertEqual(TimeoutOption.allCases.count, 9)
    }

    // MARK: - Scheduled

    func testScheduledReturnsCorrectDelta() {
        let futureDate = Date().addingTimeInterval(3600)
        let result = TimeoutOption.scheduled.seconds(customSeconds: 0, scheduledDate: futureDate)
        XCTAssertNotNil(result)
        // Allow 2s tolerance for test execution time
        XCTAssertEqual(result!, 3600, accuracy: 2)
    }

    func testScheduledClampsToMinimum60Seconds() {
        let nearFuture = Date().addingTimeInterval(10)
        let result = TimeoutOption.scheduled.seconds(customSeconds: 0, scheduledDate: nearFuture)
        XCTAssertEqual(result, 60)
    }

    func testScheduledClampsPastDateTo60Seconds() {
        let pastDate = Date().addingTimeInterval(-100)
        let result = TimeoutOption.scheduled.seconds(customSeconds: 0, scheduledDate: pastDate)
        XCTAssertEqual(result, 60)
    }

    func testScheduledReturnsNilWhenDateIsNil() {
        let result = TimeoutOption.scheduled.seconds(customSeconds: 0, scheduledDate: nil)
        XCTAssertNil(result)
    }
}
