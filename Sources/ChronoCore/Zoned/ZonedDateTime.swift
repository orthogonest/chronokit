import ChronoCalendar

public struct ZonedDateTime: Sendable {
    /// The exact moment in time, stored as UTC.
    public let instant: Instant

    /// The timezone associated with this instant.
    public let timeZone: TimeZone

    public let calendar: Calendar

    @inlinable
    public init(
        instant: Instant,
        timeZone: TimeZone,
        calendar: Calendar = .gregorian
    ) {
        self.instant = instant
        self.timeZone = timeZone
        self.calendar = calendar
    }

    public init?(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        timeZone: TimeZone,
        calendar: Calendar = .gregorian
    ) {
        guard
            let plainDateTime = PlainDateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: nanosecond,
                calendar: calendar
            ),
            let utcInstant = plainDateTime.instant(in: timeZone)
        else { return nil }

        self.init(
            instant: utcInstant,
            timeZone: timeZone,
            calendar: calendar
        )
    }
}

// MARK: - Core Accessors

public extension ZonedDateTime {
    /// Unix Timestamp (Seconds). Fast O(1).
    @inlinable
    var timestamp: Int64 {
        instant.timestamp
    }

    /// Unix Timestamp (Milliseconds). Fast O(1).
    @inlinable
    var timestampMilliseconds: Int64 {
        instant.timestampMilliseconds
    }

    /// Unix Timestamp (Microseconds). Fast O(1).
    @inlinable
    var timestampMicroseconds: Int64 {
        instant.timestampMicroseconds
    }

    /// Unix Timestamp (Nanoseconds). Fast O(1).
    @inlinable
    var timestampNanoSeconds: Int64 {
        instant.timestampNanoseconds
    }

    @inlinable
    var timestampNanosecondsChecked: Int64? {
        instant.timestampNanosecondsChecked
    }
}

// MARK: - Equality

extension ZonedDateTime: Equatable {
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        // Comparison is always done on the absolute instant (UTC),
        // ignoring the timezone offset.
        lhs.instant == rhs.instant
    }
}

// MARK: - Hash

extension ZonedDateTime: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(instant)
    }
}

// MARK: - Comparability

extension ZonedDateTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        // Comparison is always done on the absolute instant (UTC),
        // ignoring the timezone offset.
        lhs.instant < rhs.instant
    }
}

// MARK: - Arithmetic

public extension ZonedDateTime {
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        Self(
            instant: instant.advanced(bySeconds: seconds, nanoseconds: nanoseconds),
            timeZone: timeZone,
            calendar: calendar
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

public extension ZonedDateTime {
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension ZonedDateTime {
    static func - (lhs: Self, rhs: Self) -> Duration {
        lhs.instant - rhs.instant
    }

    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds)
        )
    }

    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }
}

// MARK: - Date Protocol

extension ZonedDateTime: DateProtocol {
    public var year: Int {
        plainDateTime.date.year
    }

    public var month: Int {
        plainDateTime.date.month
    }

    public var day: Int {
        plainDateTime.date.day
    }

    public var ordinal: Int {
        plainDateTime.date.ordinal
    }

    public var weekday: Int {
        plainDateTime.date.weekday
    }

    public var isLeapYear: Bool {
        plainDateTime.date.isLeapYear
    }

    public var daysSinceUnixEpoch: Int {
        plainDateTime.date.daysSinceUnixEpoch
    }

    public var daysInMonth: Int {
        plainDateTime.date.daysInMonth
    }

    public func with(year: Int) -> Self? {
        withPlain { $0.with(year: year) }
    }

    public func with(month: Int) -> Self? {
        withPlain { $0.with(month: month) }
    }

    public func with(monthZeroBased value: Int) -> Self? {
        withPlain { $0.with(monthZeroBased: value) }
    }

    public func with(monthSymbol value: Month) -> Self? {
        withPlain { $0.with(monthSymbol: value) }
    }

    public func with(day: Int) -> Self? {
        withPlain { $0.with(day: day) }
    }

    public func with(dayZeroBased value: Int) -> Self? {
        withPlain { $0.with(dayZeroBased: value) }
    }

    public func with(ordinal: Int) -> Self? {
        withPlain { $0.with(ordinal: ordinal) }
    }

    public func with(ordinalZeroBased value: Int) -> Self? {
        withPlain { $0.with(ordinalZeroBased: value) }
    }

    public func with(calendar: Calendar) -> Self? {
        withPlain { $0.with(calendar: calendar) }
    }
}

// MARK: - Time Protocol

extension ZonedDateTime: TimeProtocol {
    public var hour: Int {
        plainDateTime.time.hour
    }

    public var minute: Int {
        plainDateTime.time.minute
    }

    public var second: Int {
        plainDateTime.time.second
    }

    public var nanosecond: Int {
        plainDateTime.time.nanosecond
    }

    public func with(hour: Int) -> Self? {
        withPlain { $0.with(hour: hour) }
    }

    public func with(minute: Int) -> Self? {
        withPlain { $0.with(minute: minute) }
    }

    public func with(second: Int) -> Self? {
        withPlain { $0.with(second: second) }
    }

    public func with(nanosecond: Int) -> Self? {
        withPlain { $0.with(nanosecond: nanosecond) }
    }
}

// MARK: - Subsecond Rounding

extension ZonedDateTime: SubsecondRoundable {
    public func roundSubseconds(_ digits: Int) -> Self {
        Self(
            instant: instant.roundSubseconds(digits),
            timeZone: timeZone,
            calendar: calendar
        )
    }

    public func truncateSubseconds(_ digits: Int) -> Self {
        Self(
            instant: instant.truncateSubseconds(digits),
            timeZone: timeZone,
            calendar: calendar
        )
    }
}

// MARK: - Duration Rounding

extension ZonedDateTime: DurationRoundable {
    public typealias RoundingError = TimeRoundingError

    public func round(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.round(byQuantum: quantum),
            timeZone: timeZone,
            calendar: calendar
        )
    }

    public func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.truncate(byQuantum: quantum),
            timeZone: timeZone,
            calendar: calendar
        )
    }

    public func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.roundUp(byQuantum: quantum),
            timeZone: timeZone,
            calendar: calendar
        )
    }
}

// MARK: - Plain Date Time Conversion

extension ZonedDateTime {
    /// The 'Wall Clock' view of the time.
    /// This applies the timezone offset to the stored UTC time.
    public var plainDateTime: PlainDateTime {
        instant.plainDateTime(in: timeZone, calendar: calendar)
    }

    func withPlain(
        resolving policy: DSTResolutionPolicy = .preferEarlier,
        _ transform: (PlainDateTime) -> PlainDateTime?
    ) -> Self? {
        guard let newPlain = transform(plainDateTime),
              let newInstant = newPlain.instant(
                  in: timeZone,
                  resolving: policy
              )
        else { return nil }

        return Self(
            instant: newInstant,
            timeZone: timeZone,
            calendar: calendar
        )
    }
}
