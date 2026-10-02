import ChronoCore

public extension ZonedDateTime {
    static var now: Self {
        .system(instant: .now)
    }

    static func now(in timeZone: TimeZone = .utc) -> Self {
        Self(instant: .now, timeZone: timeZone)
    }

    static var nowUTC: Self {
        now(in: .utc)
    }
}
