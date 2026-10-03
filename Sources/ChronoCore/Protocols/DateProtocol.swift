import ChronoCalendar

public protocol DateProtocol: Equatable, Comparable {
    var year: Int { get }
    var yearCE: (isCE: Bool, year: UInt32) { get }
    var isLeapYear: Bool { get }

    var quarter: Int { get }

    var month: Int { get }
    var monthZeroBased: Int { get }
    var monthSymbol: Month? { get }

    var weekday: Int { get }
    var weekdaySymbol: Weekday? { get }
    var isoWeek: ISOWeek { get }

    var day: Int { get }
    var dayZeroBased: Int { get }
    var daysSinceUnixEpoch: Int { get }
    var daysInMonth: Int { get }

    var ordinal: Int { get }
    var ordinalZeroBased: Int { get }

    func with(year: Int) -> Self?

    func with(month: Int) -> Self?
    func with(monthZeroBased value: Int) -> Self?
    func with(monthSymbol value: Month) -> Self?

    func with(day: Int) -> Self?
    func with(dayZeroBased value: Int) -> Self?

    func with(ordinal: Int) -> Self?
    func with(ordinalZeroBased value: Int) -> Self?

    func with(calendar: Calendar) -> Self?
}

public extension DateProtocol {
    @inlinable
    var yearCE: (isCE: Bool, year: UInt32) {
        if year < 1 {
            (isCE: false, year: UInt32(1 - year))
        } else {
            (isCE: true, year: UInt32(year))
        }
    }

    @inlinable
    var quarter: Int {
        (month - 1) / 3 + 1
    }

    @inlinable
    var monthZeroBased: Int {
        month - 1
    }

    @inlinable
    var monthSymbol: Month? {
        Month(rawValue: month)
    }

    @inlinable
    var dayZeroBased: Int {
        day - 1
    }

    @inlinable
    var ordinalZeroBased: Int {
        ordinal - 1
    }

    @inlinable
    var weekdaySymbol: Weekday? {
        Weekday(rawValue: weekday)
    }

    var isoWeek: ISOWeek {
        ISOWeek(year: Int64(year), month: UInt8(month), day: UInt8(day))
    }
}
