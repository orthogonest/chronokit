public struct ZonedDateTime: Sendable {
    /// The exact moment in time, stored as UTC.
    public let instant: Instant

    /// The timezone associated with this instant.
    public let timeZone: TimeZone

    @inlinable
    public init(instant: Instant, timeZone: TimeZone) {
        self.instant = instant
        self.timeZone = timeZone
    }

    @inlinable
    public init?(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        nanosecond: Int = 0,
        timeZone: TimeZone
    ) {
        guard
            let plainDateTime = PlainDateTime(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: nanosecond
            ),
            let utcInstant = plainDateTime.instant(in: timeZone)
        else { return nil }

        self.init(instant: utcInstant, timeZone: timeZone)
    }
}

// MARK: - Core Accessors

public extension ZonedDateTime {
    /// Unix Timestamp (Seconds). Fast O(1).
    @inlinable
    var timestamp: Int64 {
        instant.timestamp
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
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        Self(
            instant: instant.advanced(bySeconds: seconds, nanoseconds: nanoseconds),
            timeZone: timeZone
        )
    }

    @inlinable
    func advanced(by duration: Duration) -> Self {
        advanced(
            bySeconds: duration.seconds,
            nanoseconds: Int64(duration.nanoseconds)
        )
    }
}

// MARK: - Addition

public extension ZonedDateTime {
    @inlinable
    static func + (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(by: rhs)
    }

    @inlinable
    static func + (lhs: Duration, rhs: Self) -> Self {
        rhs.advanced(by: lhs)
    }

    @inlinable
    static func += (lhs: inout Self, rhs: Duration) {
        lhs = lhs + rhs
    }
}

// MARK: - Substraction

public extension ZonedDateTime {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Duration {
        let instant = lhs.instant - rhs.instant
        return Duration(seconds: instant.seconds, nanoseconds: Int64(instant.nanoseconds))
    }

    @inlinable
    static func - (lhs: Self, rhs: Duration) -> Self {
        lhs.advanced(
            bySeconds: -rhs.seconds,
            nanoseconds: -Int64(rhs.nanoseconds)
        )
    }

    @inlinable
    static func -= (lhs: inout Self, rhs: Duration) {
        lhs = lhs - rhs
    }
}

// MARK: - Date Protocol

extension ZonedDateTime: DateProtocol {
    @inlinable
    public var year: Int {
        plainDateTime.date.year
    }

    @inlinable
    public var month: Int {
        plainDateTime.date.month
    }

    @inlinable
    public var day: Int {
        plainDateTime.date.day
    }

    @inlinable
    public var ordinal: Int {
        plainDateTime.date.ordinal
    }

    @inlinable
    public var weekday: Int {
        plainDateTime.date.weekday
    }

    @inlinable
    public func with(year: Int) -> Self? {
        withPlain { $0.with(year: year) }
    }

    @inlinable
    public func with(month: Int) -> Self? {
        withPlain { $0.with(month: month) }
    }

    @inlinable
    public func with(monthZeroBased value: Int) -> Self? {
        withPlain { $0.with(monthZeroBased: value) }
    }

    @inlinable
    public func with(monthSymbol value: Month) -> Self? {
        withPlain { $0.with(monthSymbol: value) }
    }

    @inlinable
    public func with(day: Int) -> Self? {
        withPlain { $0.with(day: day) }
    }

    @inlinable
    public func with(dayZeroBased value: Int) -> Self? {
        withPlain { $0.with(dayZeroBased: value) }
    }

    @inlinable
    public func with(ordinal: Int) -> Self? {
        withPlain { $0.with(ordinal: ordinal) }
    }

    @inlinable
    public func with(ordinalZeroBased value: Int) -> Self? {
        withPlain { $0.with(ordinalZeroBased: value) }
    }
}

// MARK: - Time Protocol

extension ZonedDateTime: TimeProtocol {
    @inlinable
    public var hour: Int {
        plainDateTime.time.hour
    }

    @inlinable
    public var minute: Int {
        plainDateTime.time.minute
    }

    @inlinable
    public var second: Int {
        plainDateTime.time.second
    }

    @inlinable
    public var nanosecond: Int {
        plainDateTime.time.nanosecond
    }

    @inlinable
    public func with(hour: Int) -> Self? {
        withPlain { $0.with(hour: hour) }
    }

    @inlinable
    public func with(minute: Int) -> Self? {
        withPlain { $0.with(minute: minute) }
    }

    @inlinable
    public func with(second: Int) -> Self? {
        withPlain { $0.with(second: second) }
    }

    @inlinable
    public func with(nanosecond: Int) -> Self? {
        withPlain { $0.with(nanosecond: nanosecond) }
    }
}

// MARK: - Subsecond Rounding

extension ZonedDateTime: SubsecondRoundable {
    @inlinable
    public func roundSubseconds(_ digits: Int) -> Self {
        Self(
            instant: instant.roundSubseconds(digits),
            timeZone: timeZone
        )
    }

    @inlinable
    public func truncateSubseconds(_ digits: Int) -> Self {
        Self(
            instant: instant.truncateSubseconds(digits),
            timeZone: timeZone
        )
    }
}

// MARK: - Duration Rounding

extension ZonedDateTime: DurationRoundable {
    public typealias RoundingError = TimeRoundingError

    @inlinable
    public func round(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.round(byQuantum: quantum),
            timeZone: timeZone
        )
    }

    @inlinable
    public func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.truncate(byQuantum: quantum),
            timeZone: timeZone
        )
    }

    @inlinable
    public func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        try Self(
            instant: instant.roundUp(byQuantum: quantum),
            timeZone: timeZone
        )
    }
}

// MARK: - Plain Date Time Conversion

extension ZonedDateTime {
    /// The 'Wall Clock' view of the time.
    /// This applies the timezone offset to the stored UTC time.
    @inlinable
    public var plainDateTime: PlainDateTime {
        instant.plainDateTime(in: timeZone)
    }

    @usableFromInline
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

        return Self(instant: newInstant, timeZone: timeZone)
    }
}
