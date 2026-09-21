import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct ZonedDateTimeFoundationTests {
    // MARK: - From Foundadtion Tests

    @Test("ZonedDateTimeTests: Initialize from Foundation.DateComponents and ChronoCore.TimeZone")
    func initializeFromComponentsAndTimeZone() throws {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 21
        components.hour = 15
        components.minute = 30
        components.second = 0
        components.nanosecond = 0

        let chronoTimeZone: ChronoCore.TimeZone = .utc
        let zonedDateTime: ChronoCore.ZonedDateTime = try #require(ZonedDateTime(
            foundation: components,
            timeZone: chronoTimeZone
        ))

        #expect(zonedDateTime.year == 2026)
        #expect(zonedDateTime.hour == 15)
        #expect(zonedDateTime.day == 21)
        #expect(components.hour == 15)
        #expect(components.minute == 30)
        #expect(components.second == 0)
        #expect(components.nanosecond == 0)
        #expect(zonedDateTime.timeZone == chronoTimeZone)
    }

    @Test("ZonedDateTimeTests: Initialize from Foundation.Date and ChronoCore.TimeZone")
    func initializeFromDateAndTimeZone() {
        let interval: Foundation.TimeInterval = 1000.5 // 1000 seconds + 500_000_000 nanoseconds
        let date = Foundation.Date(timeIntervalSince1970: interval)
        let chronoTimeZone: ChronoCore.TimeZone = .utc

        let zonedDateTime = ChronoCore.ZonedDateTime(foundation: date, timeZone: chronoTimeZone)

        #expect(zonedDateTime.instant.seconds == 1000)
        #expect(zonedDateTime.instant.nanoseconds == 500_000_000)
        #expect(zonedDateTime.timeZone == chronoTimeZone)
    }
}

// MARK: - From ChronoKit Tests

extension ZonedDateTimeFoundationTests {
    @Test("ZonedDateTimeTests: Foundation.DateComponents from ChronoCore.ZonedDateTime")
    func componentsFromChronoZonedDateTime() {
        let instant = ChronoCore.Instant(seconds: 0, nanoseconds: 0) // Unix Epoch UTC
        let chronoTimeZone: ChronoCore.TimeZone = .fixedOffset(seconds: 25200) // +7 Hour (Asia/Jakarta)
        let zonedDateTime = ChronoCore.ZonedDateTime(instant: instant, timeZone: chronoTimeZone)

        let components = Foundation.DateComponents(chrono: zonedDateTime)

        #expect(components.year == 1970)
        #expect(components.hour == 7, "Civil hour should reflect the specific timezone offset, not UTC")
        #expect(components.timeZone != nil)
        #expect(
            components.timeZone?.secondsFromGMT() == 25200,
            "Embedded Foundation.TimeZone must match the custom offset"
        )
    }

    @Test("ZonedDateTimeTests: Foundation.Date from ChronoCore.ZonedDateTime")
    func dateFromChronoZonedDateTime() {
        let instant = ChronoCore.Instant(seconds: 123_456, nanoseconds: 0)
        let chronoTimeZone: ChronoCore.TimeZone = .utc
        let zonedDateTime = ChronoCore.ZonedDateTime(instant: instant, timeZone: chronoTimeZone)

        let date = Foundation.Date(chrono: zonedDateTime)
        #expect(date.timeIntervalSince1970 == 123_456.0, "Date should reflect the absolute instant universally")
    }
}

// MARK: - Proxy Bridge Property Tests

extension ZonedDateTimeFoundationTests {
    @Test("ZonedDateTimeTests: Inbound bridge proxy properties (.foundation)")
    func inboundBridgeProxyProperties() {
        let instant = ChronoCore.Instant(seconds: 2000, nanoseconds: 0)
        let chronoTimeZone: ChronoCore.TimeZone = .utc
        let zonedDateTime = ChronoCore.ZonedDateTime(instant: instant, timeZone: chronoTimeZone)

        #expect(zonedDateTime.foundation.date.timeIntervalSince1970 == 2000.0)

        let components = zonedDateTime.foundation.components
        #expect(components.year == 1970)
        #expect(components.timeZone?.identifier == "GMT") // UTC identifier in Foundation
    }

    @Test("ZonedDateTimeTests: Outbound bridge proxy methods (.chrono)")
    func outboundBridgeProxyMethods() throws {
        let interval: Foundation.TimeInterval = 5000.0
        let date = Foundation.Date(timeIntervalSince1970: interval)
        let chronoTimeZone: ChronoCore.TimeZone = .utc

        let zonedDateTimeFromDate = date.chrono.zonedDateTime(timeZone: chronoTimeZone)
        #expect(zonedDateTimeFromDate.instant.seconds == 5000)

        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 21
        components.hour = 12
        components.minute = 0
        components.second = 0

        let zonedDateTimeFromComponents = try #require(components.chrono.zonedDateTime(timeZone: chronoTimeZone))
        #expect(zonedDateTimeFromComponents.year == 2026)
        #expect(zonedDateTimeFromComponents.month == 9)
        #expect(zonedDateTimeFromComponents.day == 21)
        #expect(zonedDateTimeFromComponents.hour == 12)
        #expect(zonedDateTimeFromComponents.minute == 0)
        #expect(zonedDateTimeFromComponents.second == 0)
    }
}
