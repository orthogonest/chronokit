import ChronoCore

public extension PlainTime {
    @inlinable
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timeZone).time
    }

    @inlinable
    static var now: Self {
        now(in: SystemTimeZone())
    }
}
