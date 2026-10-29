import Foundation

public let usage = "usage: DnbCal <from yyyy-MM-dd> <to yyyy-MM-dd> <output file>\n"

/// A date range (both days included) and where to write the result.
public struct Request: Equatable {
    public let from: Date
    public let end: Date // the start of the day after `to`
    public let out: String
}

private func dayFormatter(_ calendar: Calendar) -> DateFormatter {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US_POSIX")
    f.calendar = calendar
    f.timeZone = calendar.timeZone
    f.dateFormat = "yyyy-MM-dd"
    return f
}

/// `args` without the program name. nil = wrong usage.
public func parseRequest(_ args: [String], calendar: Calendar = .current) -> Request? {
    guard args.count == 3 else { return nil }
    let f = dayFormatter(calendar)
    guard let from = f.date(from: args[0]), let to = f.date(from: args[1]), from <= to,
          let end = calendar.date(byAdding: .day, value: 1, to: to) else { return nil }
    return Request(from: from, end: end, out: args[2])
}

public struct Entry: Equatable {
    public let start: Date
    public let allDay: Bool
    public let title: String?

    public init(start: Date, allDay: Bool, title: String?) {
        self.start = start
        self.allDay = allDay
        self.title = title
    }
}

/// One line per event, by start: `yyyy-MM-dd`, `HH:mm` (`-` for all-day) and the title,
/// separated by tabs. Runs of tabs and line breaks in a title become one space.
private let breaks = CharacterSet.newlines.union(CharacterSet(charactersIn: "\t"))

public func render(_ entries: [Entry], calendar: Calendar = .current) -> String {
    let day = dayFormatter(calendar)
    let time = dayFormatter(calendar)
    time.dateFormat = "HH:mm"
    return entries.sorted { $0.start < $1.start }.map { e in
        let title = (e.title ?? "").components(separatedBy: breaks).filter { !$0.isEmpty }.joined(separator: " ")
        return "\(day.string(from: e.start))\t\(e.allDay ? "-" : time.string(from: e.start))\t\(title)\n"
    }.joined()
}
