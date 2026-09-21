import ChronoMath

public struct Instant: Equatable, Hashable, Sendable {
    public let seconds: Int64
    public let nanoseconds: Int32

    @inlinable
    public init(seconds: Int64, nanoseconds: Int64 = 0) {
        if nanoseconds >= 0, nanoseconds < NanoSeconds.perSecond64 {
            self.seconds = seconds
            self.nanoseconds = Int32(nanoseconds)
            return
        }

        let extraSec = floorDiv(nanoseconds, NanoSeconds.perSecond64)
        let remNano = floorMod(nanoseconds, NanoSeconds.perSecond64)

        let (finalSec, overflow) = seconds.addingReportingOverflow(extraSec)

        if overflow {
            let isPositiveOverflow = seconds > 0 || (seconds == 0 && extraSec > 0)
            self.seconds = isPositiveOverflow ? .max : .min
        } else {
            self.seconds = finalSec
        }

        self.nanoseconds = Int32(remNano)
    }

    @inlinable
    public init(seconds: Int, nanoseconds: Int = 0) {
        self.init(seconds: Int64(seconds), nanoseconds: Int64(nanoseconds))
    }
}

// MARK: - Constructors

public extension Instant {
    static let zero: Self = .init(seconds: 0, nanoseconds: 0)
}

// MARK: - Comparability

extension Instant: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.seconds == rhs.seconds {
            return lhs.nanoseconds < rhs.nanoseconds
        }
        return lhs.seconds < rhs.seconds
    }
}

// MARK: - Core Accessor

public extension Instant {
    @inlinable
    var timestamp: Int64 {
        seconds
    }

    @inlinable
    var timestampMilliseconds: Int64 {
        seconds * MilliSeconds.perSecond64 + Int64(nanoseconds) / NanoSeconds.perMilliSecond64
    }

    @inlinable
    var timestampMicroseconds: Int64 {
        seconds * MicroSeconds.perSecond64 + Int64(nanoseconds) / NanoSeconds.perMicroSecond64
    }

    @inlinable
    var timestampNanoseconds: Int64 {
        seconds * NanoSeconds.perSecond64 + Int64(nanoseconds)
    }

    @inlinable
    var timestampNanosecondsChecked: Int64? {
        let (secPart, overflowMul) = seconds.multipliedReportingOverflow(by: NanoSeconds.perSecond64)
        if overflowMul { return nil }

        let (total, overflowSum) = secPart.addingReportingOverflow(Int64(nanoseconds))
        if overflowSum { return nil }

        return total
    }
}

// MARK: - Arithmetic

public extension Instant {
    @inlinable
    func advanced(bySeconds secs: Int64, nanoseconds nanos: Int64 = 0) -> Self {
        let targetSeconds = seconds.addingReportingOverflow(secs).partialValue
        let targetNanoseconds = Int64(nanoseconds).addingReportingOverflow(nanos).partialValue

        return Self(
            seconds: targetSeconds,
            nanoseconds: targetNanoseconds
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

public extension Instant {
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

public extension Instant {
    @inlinable
    static func - (lhs: Self, rhs: Self) -> Duration {
        let secDiff = lhs.seconds.subtractingReportingOverflow(rhs.seconds).partialValue
        let nanoDiff = Int64(lhs.nanoseconds) - Int64(rhs.nanoseconds)
        return Duration(seconds: secDiff, nanoseconds: nanoDiff)
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

// MARK: - Subsecond Rounding

extension Instant: SubsecondRoundable {
    @inlinable
    public func roundSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = Int64(nanoseconds)

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        if deltaUp <= deltaDown {
            return advanced(bySeconds: 0, nanoseconds: deltaUp)
        } else {
            return advanced(bySeconds: 0, nanoseconds: -deltaDown)
        }
    }

    @inlinable
    public func truncateSubseconds(_ digits: Int) -> Self {
        if digits >= 9 { return self }

        let span = NanosecondMath.span(forDigits: digits)
        let nanos = Int64(nanoseconds)

        let deltaDown = floorMod(nanos, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: -deltaDown)
    }
}

// MARK: - Duration Rounding

extension Instant: DurationRoundable {
    public typealias RoundingError = TimeRoundingError

    @inlinable
    public func round(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        let deltaUp = span - deltaDown

        if deltaUp <= deltaDown {
            return advanced(bySeconds: 0, nanoseconds: deltaUp)
        } else {
            return advanced(bySeconds: 0, nanoseconds: -deltaDown)
        }
    }

    @inlinable
    public func truncate(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: -deltaDown)
    }

    @inlinable
    public func roundUp(byQuantum quantum: Duration) throws(RoundingError) -> Self {
        guard let span = quantum.timestampNanosecondsChecked else { throw .quantumExceedsLimit }
        guard span > 0 else { throw .invalidQuantum }
        guard let stamp = timestampNanosecondsChecked else { throw .timestampExceedsLimit }

        let deltaDown = floorMod(stamp, span)
        if deltaDown == 0 { return self }

        return advanced(bySeconds: 0, nanoseconds: span - deltaDown)
    }
}

// MARK: - Plain Date Time Conversion

public extension Instant {
    @inlinable
    func plainDateTime(in timeZone: some TimeZoneProtocol) -> PlainDateTime {
        let offset = timeZone.offset(for: self)

        let totalSecs = seconds.addingReportingOverflow(offset.seconds).partialValue
        let totalNanos = Int64(nanoseconds) + Int64(offset.nanoseconds)

        let extraSecs = floorDiv(totalNanos, NanoSeconds.perSecond64)
        let finalNanos = floorMod(totalNanos, NanoSeconds.perSecond64)

        let plainSeconds = totalSecs + extraSecs

        let days = floorDiv(plainSeconds, Seconds.perDay64)
        let secondsOfDay = floorMod(plainSeconds, Seconds.perDay64)

        let nanosSinceMidnight = secondsOfDay * NanoSeconds.perSecond64 + finalNanos

        return PlainDateTime(
            date: PlainDate(daysSinceEpoch: days),
            time: PlainTime(nanosecondsSinceMidnight: nanosSinceMidnight)
        )
    }

    @inlinable
    var plainDateTimeUTC: PlainDateTime {
        plainDateTime(in: FixedOffset.utc)
    }
}

// MARK: - Zoned Date Time Conversion

public extension Instant {
    @inlinable
    func zonedDateTime(in timeZone: TimeZone) -> ZonedDateTime {
        ZonedDateTime(instant: self, timeZone: timeZone)
    }

    @inlinable
    var zonedDateTimeUTC: ZonedDateTime {
        zonedDateTime(in: .utc)
    }
}
