import DnbCalCore
import EventKit
import Foundation

// Writes the Apple Calendar events of a date range to a file, in the format `render` documents;
// the file holds just "DENIED" when Calendar access is refused. Started through `open` (see the
// README), so macOS asks for access under this app's name.

guard let request = parseRequest(Array(CommandLine.arguments.dropFirst())) else {
    FileHandle.standardError.write(Data(usage.utf8))
    exit(2)
}

func write(_ text: String) {
    try? text.write(toFile: request.out, atomically: true, encoding: .utf8) // temp file + rename: readers never see half a file
}

let store = EKEventStore()
let answered = DispatchSemaphore(value: 0)
var granted = false
if #available(macOS 14, *) {
    store.requestFullAccessToEvents { ok, _ in granted = ok; answered.signal() }
} else {
    store.requestAccess(to: .event) { ok, _ in granted = ok; answered.signal() }
}
answered.wait()

guard granted else {
    write("DENIED\n")
    exit(0)
}

let events = store.events(matching: store.predicateForEvents(withStart: request.from, end: request.end, calendars: nil))
write(render(events.map { Entry(start: $0.startDate, allDay: $0.isAllDay, title: $0.title) }))
