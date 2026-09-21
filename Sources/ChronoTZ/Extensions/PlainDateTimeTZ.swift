import ChronoCore
import ChronoMath

public extension PlainDateTime {
    @inlinable
    func instant(
        in name: String,
        resolving policy: DSTResolutionPolicy = .preferEarlier,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> Instant {
        let timezone = try provider.timeZone(named: name)
        guard let instant = instant(in: timezone, resolving: policy) else {
            throw TimeZoneError.zoneNotFound(name)
        }
        return instant
    }

    @inlinable
    func zonedDateTime(
        timeZone name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> ZonedDateTime {
        let timeZone = try provider.timeZone(named: name)
        guard let dt = zonedDateTime(timeZone: .tzif(timeZone)) else {
            throw TimeZoneError.zoneNotFound(name)
        }
        return dt
    }
}
