import ChronoMath

public struct PlainTime: Equatable, Hashable, Sendable {
    @usableFromInline package let nanosecondsSinceMidnight: Int64

    @inlinable
    public init(nanosecondsSinceMidnight: Int64) {
        precondition(
            nanosecondsSinceMidnight >= 0 && nanosecondsSinceMidnight < NanoSeconds.perDay64,
            "Time out of bounds"
        )
        self.nanosecondsSinceMidnight = nanosecondsSinceMidnight
    }

    @inlinable
    public init?(hour: Int, minute: Int, second: Int, nanosecond: Int = 0) {
        guard hour >= 0, hour < 24,
              minute >= 0, minute < 60,
              second >= 0, second < 60,
              nanosecond >= 0, nanosecond < NanoSeconds.perSecond64
        else { return nil }

        nanosecondsSinceMidnight = Int64(hour) * NanoSeconds.perHour64
            + Int64(minute) * NanoSeconds.perMinute64
            + Int64(second) * NanoSeconds.perSecond64
            + Int64(nanosecond)
    }
}

// MARK: - Comparability

extension PlainTime: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.nanosecondsSinceMidnight < rhs.nanosecondsSinceMidnight
    }
}

// MARK: - Constructors

public extension PlainTime {
    static let min: Self = .init(nanosecondsSinceMidnight: 0)
    static let max: Self = .init(nanosecondsSinceMidnight: NanoSeconds.perDay64 - 1)
    static let midnight: Self = .min
}

// MARK: - Arithmetic

public extension PlainTime {
    @inlinable
    func advanced(bySeconds seconds: Int64, nanoseconds: Int64 = 0) -> Self {
        let boundedSeconds = floorMod(seconds, Seconds.perDay64)
        let deltaNanos = (boundedSeconds * NanoSeconds.perSecond64) + nanoseconds
        let totalNanos = nanosecondsSinceMidnight + deltaNanos
        let wrappedNanos = floorMod(totalNanos, NanoSeconds.perDay64)
        return Self(nanosecondsSinceMidnight: wrappedNanos)
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

public extension PlainTime {
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

public extension PlainTime {
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

// MARK: - Time Protocol

extension PlainTime: TimeProtocol {
    @inlinable public var hour: Int {
        Int(nanosecondsSinceMidnight / NanoSeconds.perHour64)
    }

    @inlinable public var minute: Int {
        Int((nanosecondsSinceMidnight % NanoSeconds.perHour64) / NanoSeconds.perMinute64)
    }

    @inlinable public var second: Int {
        Int((nanosecondsSinceMidnight % NanoSeconds.perMinute64) / NanoSeconds.perSecond64)
    }

    @inlinable public var nanosecond: Int {
        Int(nanosecondsSinceMidnight % NanoSeconds.perSecond64)
    }

    @inlinable
    public func with(hour: Int) -> Self? {
        guard hour >= 0, hour < 24 else { return nil }
        let remainder = nanosecondsSinceMidnight % NanoSeconds.perHour64
        let newNanos = (Int64(hour) * NanoSeconds.perHour64) + remainder
        return Self(nanosecondsSinceMidnight: newNanos)
    }

    @inlinable
    public func with(minute: Int) -> Self? {
        guard minute >= 0, minute < 60 else { return nil }
        let currentHour = (nanosecondsSinceMidnight / NanoSeconds.perHour64) * NanoSeconds.perHour64
        let currentSecondAndNano = nanosecondsSinceMidnight % NanoSeconds.perMinute64
        let newNanos = currentHour + (Int64(minute) * NanoSeconds.perMinute64) + currentSecondAndNano
        return Self(nanosecondsSinceMidnight: newNanos)
    }

    @inlinable
    public func with(second: Int) -> Self? {
        guard second >= 0, second < 60 else { return nil }
        let currentMinute = (nanosecondsSinceMidnight / NanoSeconds.perMinute64) * NanoSeconds.perMinute64
        let currentNano = nanosecondsSinceMidnight / NanoSeconds.perSecond64
        let newNanos = currentMinute + (Int64(second) * NanoSeconds.perSecond64) + currentNano
        return Self(nanosecondsSinceMidnight: newNanos)
    }

    @inlinable
    public func with(nanosecond: Int) -> Self? {
        guard nanosecond >= 0, nanosecond < NanoSeconds.perSecond64 else { return nil }
        let currentSecond = (nanosecondsSinceMidnight / NanoSeconds.perSecond64) * NanoSeconds.perSecond64
        let newNanos = currentSecond + Int64(nanosecond)
        return Self(nanosecondsSinceMidnight: newNanos)
    }
}

// MARK: - Subsecond Rounding

extension PlainTime: SubsecondRoundable {
    public func roundSubseconds(_ digits: Int) -> PlainTime {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = nanosecondsSinceMidnight

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        let finalNanos: Int64 = if deltaUp <= deltaDown {
            floorMod(nanos + deltaUp, NanoSeconds.perDay64)
        } else {
            nanos - deltaDown
        }

        return Self(nanosecondsSinceMidnight: finalNanos)
    }

    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = nanosecondsSinceMidnight

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        return Self(nanosecondsSinceMidnight: nanos - deltaDown)
    }
}

// MARK: - Plain Date Time Conversion

public extension PlainTime {
    @inlinable
    func on(_ date: PlainDate) -> PlainDateTime {
        PlainDateTime(date: date, time: self)
    }

    @inlinable
    func on(daysSinceEpoch days: Int64) -> PlainDateTime {
        PlainDateTime(
            date: PlainDate(daysSinceEpoch: days),
            time: self
        )
    }

    @inlinable
    func on(year: Int32, month: UInt8, day: UInt8) -> PlainDateTime? {
        guard let date = PlainDate(year: year, month: month, day: day) else { return nil }
        return PlainDateTime(
            date: date,
            time: self
        )
    }

    @inlinable
    func on(year: Int, month: Int, day: Int) -> PlainDateTime? {
        guard let date = PlainDate(year: year, month: month, day: day) else { return nil }
        return PlainDateTime(
            date: date,
            time: self
        )
    }
}
