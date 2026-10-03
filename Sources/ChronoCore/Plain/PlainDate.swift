import ChronoCalendar

public struct PlainDate: Hashable, Sendable {
    @usableFromInline package let daysSinceEpoch: Int64
    @usableFromInline package let _year: Int32
    @usableFromInline package let _month: UInt8
    @usableFromInline package let _day: UInt8
    @usableFromInline package let calendar: Calendar

    public init(
        daysSinceEpoch days: Int64,
        calendar: Calendar = .gregorian
    ) {
        precondition(
            days >= CalendarConstants.minInputDay && days <= CalendarConstants.maxInputDay,
            "Day since epoch exceeds maximum supported calendar range."
        )

        let civil = calendar.dateComponents(from: days)

        daysSinceEpoch = days
        _year = Int32(civil.year)
        _month = civil.month
        _day = civil.day
        self.calendar = calendar
    }

    public init?(
        year: Int32,
        month: UInt8,
        day: UInt8,
        calendar: Calendar = .gregorian
    ) {
        guard month >= 1, month <= 12 else { return nil }

        guard day >= 1, day <= lastDayOfMonth(Int64(year), month)
        else { return nil }

        daysSinceEpoch = calendar.daySinceEpoch(year: Int64(year), month: month, day: day)
        _year = year
        _month = month
        _day = day
        self.calendar = calendar
    }

    public init?(
        year: Int,
        month: Int,
        day: Int,
        calendar: Calendar = .gregorian
    ) {
        self.init(
            year: Int32(year),
            month: UInt8(month),
            day: UInt8(day),
            calendar: calendar
        )
    }
}

// MARK: - Equitability

extension PlainDate: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.daysSinceEpoch == rhs.daysSinceEpoch
    }
}

// MARK: - Comparability

extension PlainDate: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.daysSinceEpoch < rhs.daysSinceEpoch
    }
}

// MARK: - Constructors

public extension PlainDate {
    static let min: Self = .init(daysSinceEpoch: CalendarConstants.minInputDay, calendar: .gregorian)
    static let max: Self = .init(daysSinceEpoch: CalendarConstants.maxInputDay, calendar: .gregorian)
    static let unixEpoch: Self = .init(daysSinceEpoch: 0, calendar: .gregorian)

    @usableFromInline
    internal var jan1: Int64 {
        calendar.daySinceEpoch(year: Int64(_year), month: 1, day: 1)
    }
}

// MARK: - Arithmetic

public extension PlainDate {
    @inlinable
    func advanced(byDays days: Int64) -> Self {
        Self(daysSinceEpoch: daysSinceEpoch + days, calendar: calendar)
    }
}

// MARK: - Addition

public extension PlainDate {
    @inlinable
    static func + (lhs: Self, rhs: Int64) -> Self {
        lhs.advanced(byDays: rhs)
    }

    @inlinable
    static func + (lhs: Int64, rhs: Self) -> Self {
        rhs.advanced(byDays: lhs)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Int64) {
        lhs = lhs + rhs
    }

    static func + (lhs: Self, rhs: CalendarInterval) -> Self {
        var newYear = Int64(lhs._year)
        var newMonth = Int64(lhs._month) + Int64(rhs.month)

        // Normalize months using your floor math (1-based: 1...12)
        // Subtract 1 to make it 0-indexed for the math, then add 1 back.
        let yearAdjustment = floorDiv(newMonth - 1, 12)
        newYear += yearAdjustment
        newMonth = floorMod(newMonth - 1, 12) + 1

        // Saturate/Clamp the day
        // Example: Jan 31 + 1 Month -> Feb 28 (or 29)
        let maxDayInMonth = lastDayOfMonth(newYear, UInt8(newMonth))
        let clampedDay = Swift.min(Int64(lhs._day), Int64(maxDayInMonth))

        let baseDays = daysFromCivil(year: newYear, month: UInt8(newMonth), day: UInt8(clampedDay))

        return Self(
            daysSinceEpoch: baseDays + Int64(rhs.day),
            calendar: lhs.calendar
        )
    }
}

// MARK: - Substraction

public extension PlainDate {
    @inlinable
    static func - (lhs: Self, rhs: Int64) -> Self {
        lhs.advanced(byDays: -rhs)
    }

    @inlinable
    static func - (lhs: Self, rhs: Self) -> Int64 {
        lhs.daysSinceEpoch - rhs.daysSinceEpoch
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Int64) {
        lhs = lhs - rhs
    }
}

// MARK: - Date Protocol

extension PlainDate: DateProtocol {
    @inlinable
    public var year: Int {
        Int(_year)
    }

    @inlinable
    public var month: Int {
        Int(_month)
    }

    @inlinable
    public var day: Int {
        Int(_day)
    }

    @inlinable
    public var ordinal: Int {
        Int(daysSinceEpoch - jan1 + 1)
    }

    public var weekday: Int {
        calendar.weekday(from: daysSinceEpoch)
    }

    public var isLeapYear: Bool {
        calendar.isLeapYear(Int64(_year))
    }

    public var daysSinceUnixEpoch: Int {
        Int(calendar.daySinceEpoch(
            year: Int64(year),
            month: UInt8(month),
            day: UInt8(day)
        ))
    }

    public var daysInMonth: Int {
        Int(calendar.lastDayOfMonth(Int64(year), UInt8(month)))
    }

    public func with(year: Int) -> Self? {
        Self(year: Int32(year), month: _month, day: _day, calendar: calendar)
    }

    public func with(month: Int) -> Self? {
        Self(year: _year, month: UInt8(month), day: _day, calendar: calendar)
    }

    public func with(monthZeroBased value: Int) -> Self? {
        Self(year: _year, month: UInt8(value + 1), day: _day, calendar: calendar)
    }

    public func with(monthSymbol value: Month) -> Self? {
        Self(year: _year, month: UInt8(value.rawValue), day: _day, calendar: calendar)
    }

    public func with(day: Int) -> Self? {
        Self(year: _year, month: _month, day: UInt8(day), calendar: calendar)
    }

    public func with(dayZeroBased value: Int) -> Self? {
        Self(year: _year, month: _month, day: UInt8(value + 1), calendar: calendar)
    }

    public func with(ordinal: Int) -> Self? {
        guard ordinal >= 1, ordinal <= (isLeapYear ? 366 : 365) else { return nil }
        return Self(daysSinceEpoch: jan1 + Int64(ordinal - 1), calendar: calendar)
    }

    public func with(ordinalZeroBased value: Int) -> Self? {
        with(ordinal: value + 1)
    }

    public func with(calendar targetCalendar: Calendar) -> Self? {
        guard calendar != targetCalendar else { return self }
        let epochDays = targetCalendar.daySinceEpoch(
            year: Int64(_year),
            month: _month,
            day: _day
        )
        return Self(daysSinceEpoch: epochDays, calendar: targetCalendar)
    }
}

// MARK: - Plain Date Time Conversion

public extension PlainDate {
    @inlinable
    func at(_ time: PlainTime) -> PlainDateTime {
        PlainDateTime(date: self, time: time)
    }

    @inlinable
    func at(nanosecondsSinceMidnight second: Int64) -> PlainDateTime {
        PlainDateTime(
            date: self,
            time: PlainTime(nanosecondsSinceMidnight: second)
        )
    }

    @inlinable
    func at(hour: Int, minute: Int, second: Int, nanosecond: Int = 0) -> PlainDateTime? {
        guard let time = PlainTime(
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        ) else { return nil }
        return PlainDateTime(
            date: self,
            time: time
        )
    }
}
