import XCTest
@testable import DnbCalCore

final class CoreTests: XCTestCase {
    private var utc: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    private func date(_ s: String) -> Date {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)!
    }

    func testParsesARangeAndEndsAfterTheLastDay() throws {
        let r = try XCTUnwrap(parseRequest(["2026-10-29", "2026-11-02", "/tmp/out"], calendar: utc))
        XCTAssertEqual(r.from, date("2026-10-29T00:00:00Z"))
        XCTAssertEqual(r.end, date("2026-11-03T00:00:00Z"))
        XCTAssertEqual(r.out, "/tmp/out")
    }

    func testOneDayRange() throws {
        let r = try XCTUnwrap(parseRequest(["2026-10-29", "2026-10-29", "o"], calendar: utc))
        XCTAssertEqual(r.end, date("2026-10-30T00:00:00Z"))
    }

    func testRejectsBadUsage() {
        XCTAssertNil(parseRequest([], calendar: utc))
        XCTAssertNil(parseRequest(["2026-10-29", "2026-10-30"], calendar: utc))
        XCTAssertNil(parseRequest(["29-10-2026", "2026-10-30", "o"], calendar: utc))
        XCTAssertNil(parseRequest(["2026-11-02", "2026-10-30", "o"], calendar: utc)) // from after to
    }

    func testRendersByStartWithAllDayMarked() {
        let out = render([
            Entry(start: date("2026-10-29T16:00:00Z"), allDay: false, title: "Therapy"),
            Entry(start: date("2026-10-29T00:00:00Z"), allDay: true, title: "Work block"),
            Entry(start: date("2026-10-28T09:30:00Z"), allDay: false, title: "Standup"),
        ], calendar: utc)
        XCTAssertEqual(out, "2026-10-28\t09:30\tStandup\n2026-10-29\t-\tWork block\n2026-10-29\t16:00\tTherapy\n")
    }

    func testTitlesCannotBreakTheFormat() {
        let out = render([Entry(start: date("2026-10-29T10:00:00Z"), allDay: false, title: "a\tb\nc\r\nd")], calendar: utc)
        XCTAssertEqual(out, "2026-10-29\t10:00\ta b c d\n")
        XCTAssertEqual(out.split(separator: "\n").count, 1)
    }

    func testMissingTitleAndNoEvents() {
        XCTAssertEqual(render([Entry(start: date("2026-10-29T10:00:00Z"), allDay: false, title: nil)], calendar: utc), "2026-10-29\t10:00\t\n")
        XCTAssertEqual(render([], calendar: utc), "")
    }
}
