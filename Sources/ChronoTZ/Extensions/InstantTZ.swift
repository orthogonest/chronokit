import ChronoCore
import ChronoMath

public extension Instant {
    @inlinable
    func plainDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> PlainDateTime {
        let timeZone = try provider.timeZone(named: name)
        return plainDateTime(in: timeZone)
    }

    @inlinable
    func zonedDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> ZonedDateTime {
        let timeZone = try provider.timeZone(named: name)
        return zonedDateTime(in: .tzif(timeZone))
    }
}
