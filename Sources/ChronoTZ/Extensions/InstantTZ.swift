import ChronoCore

public extension Instant {
    func plainDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> PlainDateTime {
        let timeZone = try provider.timeZone(named: name)
        return plainDateTime(in: timeZone)
    }

    func zonedDateTime(
        in name: String,
        provider: some TimeZoneProvider = IANAProvider.shared
    ) throws -> ZonedDateTime {
        let timeZone = try provider.timeZone(named: name)
        return zonedDateTime(in: .tzif(timeZone))
    }
}
