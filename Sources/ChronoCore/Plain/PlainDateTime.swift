import ChronoCalendar

public struct PlainDateTime: Equatable, Hashable, Sendable {
    public let date: PlainDate
    public let time: PlainTime

    @inlinable
    public init(date: PlainDate, time: PlainTime) {
        self.date = date
        self.time = time
    }

    public init?(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        calendar: Calendar = .gregorian
    ) {
        guard let date = PlainDate(year: year, month: month, day: day, calendar: calendar),
              let time = PlainTime(hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        else { return nil }

        self.date = date
        self.time = time
    }
}

// MARK: - Comparability

extension PlainDateTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.date == rhs.date {
            return lhs.time < rhs.time
        }

        return lhs.date < rhs.date
    }
}

// MARK: - Constructors

public extension PlainDateTime {
    static let min: Self = .init(date: .min, time: .min)
    static let max: Self = .init(date: .max, time: .max)
}

// MARK: - Arithmetic

public extension PlainDateTime {
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        let totalNanos = time.nanosecondsSinceMidnight + nanoseconds

        let extraDaysFromNanos = floorDiv(totalNanos, NanoSeconds.perDay64)
        let remNanos = floorMod(totalNanos, NanoSeconds.perDay64)

        let extraDaysFromSecs = floorDiv(seconds, Seconds.perDay64)
        let remSecs = floorMod(seconds, Seconds.perDay64)

        let finalNanosTotal = remNanos + (remSecs * NanoSeconds.perSecond64)
        let finalDayDelta = floorDiv(finalNanosTotal, NanoSeconds.perDay64)
        let finalNanos = floorMod(finalNanosTotal, NanoSeconds.perDay64)

        return Self(
            date: date.advanced(byDays: extraDaysFromNanos + extraDaysFromSecs + finalDayDelta),
            time: PlainTime(nanosecondsSinceMidnight: finalNanos)
        )
    }

    func advanced(by duration: Duration) -> Self {
        advanced(
            bySeconds: duration.seconds,
            nanoseconds: Int64(duration.nanoseconds)
        )
    }
}

// MARK: - Addition

public extension PlainDateTime {
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    static func + (lhs: Self, rhs: CalendarInterval) -> Self {
        let newDate = lhs.date + rhs

        let currentNanos = lhs.time.nanosecondsSinceMidnight
        let totalNanos = currentNanos + rhs.nanosecond

        let dayAdjustment = floorDiv(totalNanos, NanoSeconds.perDay64)
        let finalNanos = floorMod(totalNanos, NanoSeconds.perDay64)

        let epochDays = newDate.daysSinceEpoch + dayAdjustment

        let finalDate = PlainDate(daysSinceEpoch: epochDays, calendar: lhs.date.calendar)
        let finalTime = PlainTime(nanosecondsSinceMidnight: finalNanos)

        return Self(date: finalDate, time: finalTime)
    }

    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }

    static func += (lhs: inout Self, rhs: CalendarInterval) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension PlainDateTime {
    static func - (lhs: Self, rhs: Self) -> Duration {
        let dayDiff = lhs.date.daysSinceEpoch - rhs.date.daysSinceEpoch
        let nanoDiff = lhs.time.nanosecondsSinceMidnight - rhs.time.nanosecondsSinceMidnight

        let totalSec = dayDiff * Seconds.perDay64

        let extraSec = floorDiv(nanoDiff, NanoSeconds.perSecond64)
        let normalizedNanos = floorMod(nanoDiff, NanoSeconds.perSecond64)

        return Duration(
            seconds: totalSec + extraSec,
            nanoseconds: normalizedNanos
        )
    }

    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds)
        )
    }

    static func - (lhs: Self, rhs: CalendarInterval) -> Self {
        lhs + -rhs
    }

    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }

    static func -= (lhs: inout Self, rhs: CalendarInterval) {
        lhs = lhs - rhs
    }
}

// MARK: - Date Protocol

extension PlainDateTime: DateProtocol {
    @inlinable
    public var year: Int {
        date.year
    }

    @inlinable
    public var month: Int {
        date.month
    }

    @inlinable
    public var day: Int {
        date.day
    }

    @inlinable
    public var ordinal: Int {
        date.ordinal
    }

    public var weekday: Int {
        date.weekday
    }

    public var isLeapYear: Bool {
        date.isLeapYear
    }

    public var daysSinceUnixEpoch: Int {
        date.daysSinceUnixEpoch
    }

    public var daysInMonth: Int {
        date.daysInMonth
    }

    public func with(year: Int) -> Self? {
        guard let newDate = date.with(year: year) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(month: Int) -> Self? {
        guard let newDate = date.with(month: month) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(monthZeroBased value: Int) -> Self? {
        guard let newDate = date.with(monthZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(monthSymbol value: Month) -> Self? {
        guard let newDate = date.with(monthSymbol: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(day: Int) -> Self? {
        guard let newDate = date.with(day: day) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(dayZeroBased value: Int) -> Self? {
        guard let newDate = date.with(dayZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(ordinal: Int) -> Self? {
        guard let newDate = date.with(ordinal: ordinal) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(ordinalZeroBased value: Int) -> Self? {
        guard let newDate = date.with(ordinalZeroBased: value) else { return nil }
        return Self(date: newDate, time: time)
    }

    public func with(calendar: Calendar) -> Self? {
        guard let newDate = date.with(calendar: calendar) else { return nil }
        return Self(date: newDate, time: time)
    }
}

// MARK: - Time Protocol

extension PlainDateTime: TimeProtocol {
    @inlinable
    public var hour: Int {
        time.hour
    }

    @inlinable
    public var minute: Int {
        time.minute
    }

    @inlinable
    public var second: Int {
        time.second
    }

    @inlinable
    public var nanosecond: Int {
        time.nanosecond
    }

    @inlinable
    public func with(hour: Int) -> Self? {
        guard let newTime = time.with(hour: hour) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(minute: Int) -> Self? {
        guard let newTime = time.with(minute: minute) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(second: Int) -> Self? {
        guard let newTime = time.with(second: second) else { return nil }
        return Self(date: date, time: newTime)
    }

    @inlinable
    public func with(nanosecond: Int) -> Self? {
        guard let newTime = time.with(nanosecond: nanosecond) else { return nil }
        return Self(date: date, time: newTime)
    }
}

// MARK: - Nanos Timestamp

package extension PlainDateTime {
    @inlinable
    var timestampNanosecondsChecked: Int64? {
        let (daysStamp, daysOverflow) = date
            .daysSinceEpoch
            .multipliedReportingOverflow(by: NanoSeconds.perDay64)
        let (stamp, stampOverflow) = daysStamp
            .addingReportingOverflow(time.nanosecondsSinceMidnight)
        return (daysOverflow || stampOverflow) ? nil : stamp
    }

    static func fromTimestampNanoseconds(
        _ timestamp: Int64,
        calendar: Calendar = .gregorian
    ) -> Self {
        let days = floorDiv(timestamp, NanoSeconds.perDay64)
        let nanos = floorMod(timestamp, NanoSeconds.perDay64)

        return Self(
            date: PlainDate(daysSinceEpoch: days, calendar: calendar),
            time: PlainTime(nanosecondsSinceMidnight: nanos)
        )
    }
}

// MARK: - Subsecond Rounding

extension PlainDateTime: SubsecondRoundable {
    public func roundSubseconds(_ digits: Int) -> Self {
        if digits >= 9 {
            return self
        }

        let span = NanosecondMath.span(forDigits: digits)
        guard let timestamp = timestampNanosecondsChecked else { return self }

        let deltaDown = floorMod(timestamp, span)
        if deltaDown == 0 {
            return self
        }

        let deltaUp = span - deltaDown

        let rounded = deltaUp <= deltaDown
            ? timestamp + deltaUp
            : timestamp - deltaDown

        return Self.fromTimestampNanoseconds(rounded, calendar: date.calendar)
    }

    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 {
            return self
        }

        let span = NanosecondMath.span(forDigits: digits)
        guard let timestamp = timestampNanosecondsChecked else { return self }

        let deltaDown = floorMod(timestamp, span)
        if deltaDown == 0 {
            return self
        }

        let truncated = timestamp - deltaDown

        return Self.fromTimestampNanoseconds(truncated, calendar: date.calendar)
    }
}

// MARK: - Duration Rounding

extension PlainDateTime: DurationRoundable {
    public typealias RoundingError = TimeRoundingError

    public func round(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let timestamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(timestamp, span)
        if deltaDown == 0 {
            return self
        }

        let deltaUp = span - deltaDown

        let rounded = deltaUp <= deltaDown
            ? timestamp + deltaUp
            : timestamp - deltaDown

        return Self.fromTimestampNanoseconds(rounded, calendar: date.calendar)
    }

    public func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let timestamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(timestamp, span)
        if deltaDown == 0 {
            return self
        }

        let truncated = timestamp - deltaDown

        return Self.fromTimestampNanoseconds(truncated, calendar: date.calendar)
    }

    public func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let timestamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(timestamp, span)
        if deltaDown == 0 {
            return self
        }

        let roundedUp = timestamp + (span - deltaDown)

        return Self.fromTimestampNanoseconds(roundedUp, calendar: date.calendar)
    }
}

// MARK: - Instant Conversion

public extension PlainDateTime {
    @inlinable
    var instantUTC: Instant {
        instant(offset: .utc)
    }

    func instant(
        in timeZone: some TimeZoneProtocol,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) -> Instant? {
        guard let offset = timeZone.offset(for: self).resolve(using: policy) else { return nil }

        let daysInSecs = date.daysSinceEpoch * Seconds.perDay64

        let (rawSecs, overflow) = daysInSecs.subtractingReportingOverflow(offset.duration.seconds)
        if overflow {
            return nil
        }

        let rawNanos = time.nanosecondsSinceMidnight - Int64(offset.duration.nanoseconds)

        return Instant(seconds: rawSecs, nanoseconds: rawNanos)
    }

    func instant(offset: FixedOffset) -> Instant {
        let daysInSecs = date.daysSinceEpoch * Seconds.perDay64

        let rawSecs = daysInSecs.subtractingReportingOverflow(offset.duration.seconds).partialValue
        let rawNanos = time.nanosecondsSinceMidnight - Int64(offset.duration.nanoseconds)

        return Instant(seconds: rawSecs, nanoseconds: rawNanos)
    }
}

// MARK: - Zoned Date Time Conversion

public extension PlainDateTime {
    @inlinable
    var zonedDateTimeUTC: ZonedDateTime {
        instantUTC.zonedDateTimeUTC
    }

    func zonedDateTime(timeZone: TimeZone) -> ZonedDateTime? {
        guard let instant = instant(in: timeZone) else { return nil }
        return instant.zonedDateTime(in: timeZone, calendar: date.calendar)
    }

    func zonedDateTime(offset: FixedOffset) -> ZonedDateTime {
        let timeZone = TimeZone(offset)
        return instant(offset: offset).zonedDateTime(in: timeZone, calendar: date.calendar)
    }
}
