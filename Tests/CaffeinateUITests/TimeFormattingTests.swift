import XCTest
@testable import CaffeinateCore

final class TimeFormattingTests: XCTestCase {
    func testZeroSeconds() {
        XCTAssertEqual(formatDuration(0), "0:00")
    }

    func testUnderOneMinute() {
        XCTAssertEqual(formatDuration(59), "0:59")
    }

    func testExactlyOneMinute() {
        XCTAssertEqual(formatDuration(60), "1:00")
    }

    func testMinutesAndSeconds() {
        XCTAssertEqual(formatDuration(125), "2:05")
    }

    func testExactlyOneHour() {
        XCTAssertEqual(formatDuration(3600), "1:00:00")
    }

    func testHoursMinutesSeconds() {
        XCTAssertEqual(formatDuration(3661), "1:01:01")
    }

    func testLargeDuration() {
        // 8 hours = 28800 seconds (the -u override duration)
        XCTAssertEqual(formatDuration(28800), "8:00:00")
    }
}
