import EventKit
import Foundation

// Writes the Apple Calendar events of a date range to a file, in the format `render` documents;
// the file holds just "DENIED" when Calendar access is refused. Started through `open` (see the
// README), so macOS asks for access under this app's name.

let args = Array(CommandLine.arguments.dropFirst())
let day = ISO8601DateFormatter()
day.formatOptions = [.withFullDate]
day.timeZone = .current
guard args.count == 3, let from = day.date(from: args[0]), let to = day.date(from: args[1]), from <= to,
      let end = Calendar.current.date(byAdding: .day, value: 1, to: to) else {
    FileHandle.standardError.write(Data("usage: DnbCal <from yyyy-MM-dd> <to yyyy-MM-dd> <output file>\n".utf8))
    exit(2)
}
let out = args[2]

func write(_ text: String) {
    try? text.write(toFile: out, atomically: true, encoding: .utf8) // temp file + rename: readers never see half a file
}

let store = EKEventStore()
let answered = DispatchSemaphore(value: 0)
var granted = false
store.requestAccess(to: .event) { ok, _ in granted = ok; answered.signal() }
answered.wait()

guard granted else {
    write("DENIED\n")
    exit(0)
}

let events = store.events(matching: store.predicateForEvents(withStart: from, end: end, calendars: nil))
write(render(events.map { Entry(start: $0.startDate, allDay: $0.isAllDay, title: $0.title) }))
