import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct TimeZoneFoundationTests {
    // MARK: - From Foundadtion Tests

    @Test("TimeZoneTests: Initialize Foundation.TimeZone from IANA identifier")
    func initializeFromIANAIdentifier() throws {
        let chronoZone: ChronoCore.TimeZone = .utc
        let foundationZone: Foundation.TimeZone = try #require(TimeZone(chrono: chronoZone))

        #expect(foundationZone.identifier == "GMT", "Should match the core UTC identifier")
    }

    @Test("TimeZoneTests: Initialize Foundation.TimeZone from FixedOffset string (+/-)")
    func initializeFromFixedOffset() throws {
        let fixedOffset: ChronoCore.FixedOffset = try #require(FixedOffset(hours: 7, minutes: 0, sign: .plus))
        let chronoZone = ChronoCore.TimeZone(fixedOffset)
        let foundationZone: Foundation.TimeZone = try #require(TimeZone(chrono: chronoZone))

        #expect(foundationZone.identifier == "GMT+0700" || foundationZone.identifier == "GMT+07:00")
        #expect(foundationZone.secondsFromGMT() == 25200, "Offset should be exactly 7 hours in seconds")
    }
}

// MARK: - From ChronoKit Tests

extension TimeZoneFoundationTests {
    @Test("TimeZoneTests: Calculate offset for absolute Instant")
    func offsetForInstant() throws {
        let foundationZone: Foundation.TimeZone = try #require(TimeZone(identifier: "Asia/Jakarta"))
        let instant = Instant(seconds: 0, nanoseconds: 0) // Unix Epoch

        let offsetDuration = foundationZone.offset(for: instant)

        #expect(offsetDuration.seconds == 25200, "Offset duration should be exactly 7 hours")
    }

    @Test("TimeZoneTests: Calculate unique offset for PlainDateTime")
    func offsetForPlainDateTimeUnique() throws {
        let foundationZone: Foundation.TimeZone = try #require(TimeZone(identifier: "America/New_York"))

        // Create civil date and time at winter (Standard Time, -5 hour = -18000 second)
        let date: ChronoCore.PlainDate = try #require(PlainDate(year: 2026, month: 12, day: 25))
        let time: ChronoCore.PlainTime = try #require(PlainTime(hour: 12, minute: 0, second: 0, nanosecond: 0))
        let plainDateTime = ChronoCore.PlainDateTime(date: date, time: time)

        let plainOffset = foundationZone.offset(for: plainDateTime)

        switch plainOffset {
        case let .unique(metadata):
            #expect(metadata.duration.seconds == -18000, "New York standard offset must be -5 hours")
            #expect(metadata.isDST == false, "December must be Standard Time, not DST")
        case .ambiguous, .invalid:
            Issue.record("Expected a unique offset for a standard winter date")
        }
    }
}

// MARK: - Proxy Bridge Property Tests

extension TimeZoneFoundationTests {
    @Test("TimeZoneTests: Inbound bridge proxy property (.foundation.timeZone)")
    func inboundBridgeProxyProperty() throws {
        let fixedOffset: ChronoCore.FixedOffset = try #require(FixedOffset(hours: 5, minutes: 30, sign: .minus))
        let chronoZone = ChronoCore.TimeZone(fixedOffset)

        let foundationZone = try #require(chronoZone.foundation.timeZone)
        #expect(foundationZone.secondsFromGMT() == -19800)
    }

    @Test("TimeZoneTests: Outbound bridge proxy property (.chrono.timeZone)")
    func outboundBridgeProxyProperty() throws {
        let foundationZone: Foundation.TimeZone = try #require(TimeZone(identifier: "Europe/London"))
        let chronoZone = foundationZone.chrono.timeZone

        #expect(chronoZone.identifier == "Europe/London", "Proxy outbound must wrap the identifier properly")
    }
}
