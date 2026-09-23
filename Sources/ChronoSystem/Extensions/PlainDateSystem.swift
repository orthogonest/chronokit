import ChronoCore

public extension PlainDate {
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timeZone).date
    }

    static var now: Self {
        now(in: SystemTimeZone())
    }
}
