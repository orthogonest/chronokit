import ChronoCore

public extension PlainDateTime {
    @inlinable
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        Instant.now.plainDateTime(in: timeZone)
    }

    @inlinable
    static var now: Self {
        now(in: SystemTimeZone())
    }
}
