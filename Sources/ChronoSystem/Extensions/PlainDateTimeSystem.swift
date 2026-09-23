import ChronoCore

public extension PlainDateTime {
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        Instant.now.plainDateTime(in: timeZone)
    }

    static var now: Self {
        now(in: SystemTimeZone())
    }
}
