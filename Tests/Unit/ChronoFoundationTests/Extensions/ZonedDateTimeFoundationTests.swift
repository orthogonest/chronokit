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

    @Test("ZonedDateTimeTests: Resolve DST ambiguous overlap using preferEarlier policy")
    func resolveDSTOverlapPreferEarlier() throws {
        // In New York on November 1, 2026 at 01:30 AM, wall-clock time occurs twice
        // because clocks are turned back 1 hour due to the Autumn DST transition (Overlap).
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 11
        components.day = 1
        components.hour = 1
        components.minute = 30
        components.second = 0
        components.nanosecond = 0

        let chronoOptionalTimeZone = Foundation.TimeZone(identifier: "America/New_York")
        let chronoTimeZone = try #require(chronoOptionalTimeZone).chrono.timeZone

        // Test .preferEarlier policy (Default) -> Resolves to the earlier offset (-4 hours = EDT)
        let zonedDateTimeEarlier: ChronoCore.ZonedDateTime = try #require(ZonedDateTime(
            foundation: components,
            timeZone: chronoTimeZone,
            resolving: .preferEarlier
        ))

        // Test .preferLater policy -> Resolves to the later offset (-5 hours = EST)
        let zonedDateTimeLater: ChronoCore.ZonedDateTime = try #require(ZonedDateTime(
            foundation: components,
            timeZone: chronoTimeZone,
            resolving: .preferLater
        ))

        // The offset between EDT (-4) vs EST (-5) produces two absolute timestamps that differ by exactly 1 hour.
        let diffInSeconds = zonedDateTimeLater.instant.seconds - zonedDateTimeEarlier.instant.seconds
        #expect(
            diffInSeconds == 3600,
            "PreferLater instant should be 1 hour later than PreferEarlier during alignment fallback"
        )
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

    @Test("ZonedDateTimeTests: Outbound proxy variants with Foundation.TimeZone and custom resolving policy")
    func outboundProxyVariantsAndPolicies() throws {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 15
        components.hour = 9
        components.minute = 0
        components.second = 0
        components.nanosecond = 0

        let foundationOptionalTimeZone = Foundation.TimeZone(identifier: "Asia/Jakarta")
        let foundationTimeZone = try #require(foundationOptionalTimeZone)
        let chronoTimeZone = foundationTimeZone.chrono.timeZone

        // Test DateComponents outbound proxy method passing a native Foundation.TimeZone
        let zonedFromCompWithFoundationTZ = try #require(components.chrono.zonedDateTime(timeZone: foundationTimeZone))
        #expect(zonedFromCompWithFoundationTZ.hour == 9)
        #expect(zonedFromCompWithFoundationTZ.timeZone.identifier == "Asia/Jakarta")

        // Test Foundation.Date outbound proxy method passing a native Foundation.TimeZone
        let date = Foundation.Date(timeIntervalSince1970: 50000)
        let zonedFromDateWithFoundationTZ = date.chrono.zonedDateTime(timeZone: foundationTimeZone)
        #expect(zonedFromDateWithFoundationTZ.instant.seconds == 50000)

        // Test .strict resolution rule behavior under a completely standard, non-ambiguous civil date
        // to verify parameter forwarding integrity to your core engine.
        let zonedStrict = components.chrono.zonedDateTime(timeZone: chronoTimeZone, resolving: .strict)
        #expect(zonedStrict != nil, "Should succeed under normal non-ambiguous dates")
    }
}
