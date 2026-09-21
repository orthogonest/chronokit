import ChronoCore

public extension PlainDate {
    @inlinable
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timeZone).date
    }

    @inlinable
    static var now: Self {
        now(in: SystemTimeZone())
    }
}
