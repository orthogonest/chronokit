import ChronoCore
import ChronoSystem

public extension ZonedDateTime {
    init(
        instant: Instant,
        timeZone name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws {
        let tz = try provider.timeZone(named: name)
        self.init(instant: instant, timeZone: .tzif(tz))
    }

    static func now(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> Self {
        try self.init(
            instant: .now,
            timeZone: name,
            provider: provider
        )
    }
}
