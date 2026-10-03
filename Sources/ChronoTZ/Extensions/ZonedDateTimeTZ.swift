import ChronoCalendar
import ChronoCore
import ChronoSystem

public extension ZonedDateTime {
    init(
        instant: Instant,
        timeZone name: String,
        provider: some TimeZoneProvider = IANAProvider.shared,
        calendar: Calendar = .gregorian
    ) throws {
        let tz = try provider.timeZone(named: name)
        self.init(
            instant: instant,
            timeZone: .tzif(tz),
            calendar: calendar
        )
    }

    static func now(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared,
        calendar: Calendar = .gregorian
    ) throws -> Self {
        try self.init(
            instant: .now,
            timeZone: name,
            provider: provider,
            calendar: calendar
        )
    }
}
