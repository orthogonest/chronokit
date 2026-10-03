import ChronoCalendar
import ChronoCore

public extension PlainDateTime {
    static func now(
        in timeZone: some TimeZoneProtocol,
        calendar: Calendar = .gregorian
    ) -> Self {
        Instant.now.plainDateTime(in: timeZone, calendar: calendar)
    }

    static var now: Self {
        now(in: SystemTimeZone(), calendar: .gregorian)
    }
}
