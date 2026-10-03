import ChronoCalendar
import ChronoCore

public extension Instant {
    func plainDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared,
        calendar: Calendar = .gregorian
    ) throws -> PlainDateTime {
        let timeZone = try provider.timeZone(named: name)
        return plainDateTime(in: timeZone, calendar: calendar)
    }

    func zonedDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared,
        calendar: Calendar = .gregorian
    ) throws -> ZonedDateTime {
        let timeZone = try provider.timeZone(named: name)
        return zonedDateTime(in: .tzif(timeZone), calendar: calendar)
    }
}
