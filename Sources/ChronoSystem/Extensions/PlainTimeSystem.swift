import ChronoCore

public extension PlainTime {
    static func now(in timeZone: some TimeZoneProtocol) -> Self {
        PlainDateTime.now(in: timeZone).time
    }

    static var now: Self {
        now(in: SystemTimeZone())
    }
}
