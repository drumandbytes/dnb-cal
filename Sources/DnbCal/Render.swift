import Foundation

struct Entry: Equatable {
    let start: Date
    let allDay: Bool
    let title: String?
}

private let breaks = CharacterSet.newlines.union(CharacterSet(charactersIn: "\t"))

/// One line per event, by start: `yyyy-MM-dd`, `HH:mm` (`-` for all-day) and the title,
/// separated by tabs. Runs of tabs and line breaks in a title become one space.
func render(_ entries: [Entry], calendar: Calendar = .current) -> String {
    let day = DateFormatter(), time = DateFormatter()
    for (f, format) in [(day, "yyyy-MM-dd"), (time, "HH:mm")] {
        f.locale = Locale(identifier: "en_US_POSIX")
        f.calendar = calendar
        f.timeZone = calendar.timeZone
        f.dateFormat = format
    }
    return entries.sorted { $0.start < $1.start }.map { e in
        let title = (e.title ?? "").components(separatedBy: breaks).filter { !$0.isEmpty }.joined(separator: " ")
        return "\(day.string(from: e.start))\t\(e.allDay ? "-" : time.string(from: e.start))\t\(title)\n"
    }.joined()
}
