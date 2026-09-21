import ChronoCore

public extension ZonedDateTime {
    @inlinable
    static var now: Self {
        .system(instant: .now)
    }

    @inlinable
    static func now(in timeZone: TimeZone = .utc) -> Self {
        Self(instant: .now, timeZone: timeZone)
    }

    @inlinable
    static var nowUTC: Self {
        now(in: .utc)
    }
}
