import ChronoCalendar
import ChronoCore

public extension ZonedDateTime {
    static var now: Self {
        .system(instant: .now, calendar: .gregorian)
    }

    static func now(
        in timeZone: TimeZone = .utc,
        calendar: Calendar = .gregorian
    ) -> Self {
        Self(instant: .now, timeZone: timeZone, calendar: calendar)
    }

    static var nowUTC: Self {
        now(in: .utc, calendar: .gregorian)
    }
}
