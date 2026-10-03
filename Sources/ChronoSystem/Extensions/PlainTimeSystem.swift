import ChronoCalendar
import ChronoCore

public extension PlainTime {
    static func now(
        in timeZone: some TimeZoneProtocol,
        calendar: Calendar = .gregorian
    ) -> Self {
        PlainDateTime.now(in: timeZone, calendar: calendar).time
    }

    static var now: Self {
        now(in: SystemTimeZone(), calendar: .gregorian)
    }
}
