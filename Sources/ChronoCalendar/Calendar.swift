public enum Calendar: UInt8, CaseIterable, Codable, Equatable, Hashable, Sendable {
    case gregorian = 0
}

extension Calendar: Identifiable {
    public var id: String {
        switch self {
        case .gregorian: return "gregorian"
        }
    }
}

package extension Calendar {
    @usableFromInline
    @inline(__always)
    func daySinceEpoch(year: Int64, month: UInt8, day: UInt8) -> Int64 {
        switch self {
        case .gregorian:
            return daysFromCivil(year: year, month: month, day: day)
        }
    }

    @usableFromInline
    @inline(__always)
    func dateComponents(from days: Int64) -> (year: Int64, month: UInt8, day: UInt8) {
        switch self {
        case .gregorian:
            return civilDate(from: days)
        }
    }

    @usableFromInline
    @inline(__always)
    func isLeapYear(_ year: Int64) -> Bool {
        switch self {
        case .gregorian:
            return ChronoCalendar.isLeapYear(year)
        }
    }

    @usableFromInline
    @inline(__always)
    func lastDayOfMonth(_ year: Int64, _ month: UInt8) -> UInt8 {
        switch self {
        case .gregorian:
            return ChronoCalendar.lastDayOfMonth(year, month)
        }
    }

    @usableFromInline
    @inline(__always)
    func weekday(from days: Int64) -> Int {
        switch self {
        case .gregorian:
            return ChronoCalendar.weekday(from: days)
        }
    }
}
