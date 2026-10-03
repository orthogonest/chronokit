import ChronoCalendar
import ChronoCore

public extension PlainDate {
    static func now(
        in timeZone: some TimeZoneProtocol,
        calendar: Calendar = .gregorian
    ) -> Self {
        PlainDateTime.now(in: timeZone, calendar: calendar).date
    }

    static var now: Self {
        now(in: SystemTimeZone(), calendar: .gregorian)
    }
}
