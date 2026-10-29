import XCTest
@testable import DnbCal

final class RenderTests: XCTestCase {
    private var utc: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    private func date(_ s: String) -> Date { ISO8601DateFormatter().date(from: s)! }

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
    }

    func testMissingTitleAndNoEvents() {
        XCTAssertEqual(render([Entry(start: date("2026-10-29T10:00:00Z"), allDay: false, title: nil)], calendar: utc), "2026-10-29\t10:00\t\n")
        XCTAssertEqual(render([], calendar: utc), "")
    }
}
