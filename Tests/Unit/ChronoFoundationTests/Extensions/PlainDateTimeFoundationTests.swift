import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct PlainDateTimeFoundationTests {
    // MARK: - From Foundadtion Tests

    @Test("PlainDateTimeFoundationTests: Initialize from valid Foundation.DateComponents")
    func initializeFromValidComponents() throws {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 21
        components.hour = 14
        components.minute = 30
        components.second = 15
        components.nanosecond = 123_456_789

        let plainDateTime = try #require(PlainDateTime(foundation: components))

        #expect(plainDateTime.year == 2026, "Year should match exactly")
        #expect(plainDateTime.month == 9, "Month should match exactly")
        #expect(plainDateTime.day == 21, "Day should match exactly")
        #expect(plainDateTime.hour == 14, "Hour should match exactly")
        #expect(plainDateTime.minute == 30, "Minute should match exactly")
        #expect(plainDateTime.second == 15, "Second should match exactly")
        #expect(plainDateTime.nanosecond == 123_456_789, "Nanosecond should match exactly")
    }

    @Test("PlainDateTimeFoundationTests: Initialize from incomplete Foundation.DateComponents")
    func initializeFromIncompleteComponents() {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9

        let plainDateTime = ChronoCore.PlainDateTime(foundation: components)

        #expect(plainDateTime == nil, "Initialization must fail if core date or time components are missing")
    }
}

// MARK: - From ChronoKit Tests

extension PlainDateTimeFoundationTests {
    @Test("PlainDateTimeFoundationTests: Foundation.DateComponents from ChronoCore.PlainDateTime without TimeZone")
    func componentsFromChronoPlainDateTimeWithoutTimeZone() throws {
        let date = try #require(PlainDate(year: 2024, month: 12, day: 25))
        let time = try #require(PlainTime(hour: 8, minute: 0, second: 0, nanosecond: 0))
        let plainDateTime = ChronoCore.PlainDateTime(date: date, time: time)

        let components = Foundation.DateComponents(chrono: plainDateTime)

        #expect(components.year == 2024)
        #expect(components.month == 12)
        #expect(components.day == 25)
        #expect(components.hour == 8)
        #expect(components.minute == 0)
        #expect(components.second == 0)
        #expect(components.nanosecond == 0)
        #expect(components.timeZone == nil, "TimeZone should be nil when not provided explicitly")
    }

    @Test("PlainDateTimeFoundationTests: Foundation.DateComponents from ChronoCore.PlainDateTime with TimeZone")
    func componentsFromChronoPlainDateTimeWithTimeZone() throws {
        let date: ChronoCore.PlainDate = try #require(PlainDate(year: 2026, month: 1, day: 1))
        let time: ChronoCore.PlainTime = try #require(PlainTime(hour: 0, minute: 0, second: 0, nanosecond: 0))
        let plainDateTime = ChronoCore.PlainDateTime(date: date, time: time)

        let chronoTimeZone: ChronoCore.TimeZone = .fixedOffset(seconds: 25200) // +07:00 (WIB)
        let components = Foundation.DateComponents(chrono: plainDateTime, timeZone: chronoTimeZone)

        #expect(components.timeZone != nil, "Foundation.TimeZone context should be populated")
        #expect(components.timeZone?.secondsFromGMT() == 25200, "The embedded timezone offset must match exactly")
    }
}

// MARK: - Proxy Bridge Property Tests

extension PlainDateTimeFoundationTests {
    @Test("PlainDateTimeFoundationTests: Inbound bridge proxy properties and functions (.foundation)")
    func inboundBridgeProxy() throws {
        let date: ChronoCore.PlainDate = try #require(PlainDate(year: 2026, month: 9, day: 21))
        let time: ChronoCore.PlainTime = try #require(PlainTime(hour: 15, minute: 45, second: 30, nanosecond: 500))
        let plainDateTime = ChronoCore.PlainDateTime(date: date, time: time)

        let cleanComponents = plainDateTime.foundation.components
        #expect(cleanComponents.timeZone == nil)
        #expect(cleanComponents.hour == 15)

        let chronoTimeZone: ChronoCore.TimeZone = .fixedOffset(seconds: -18000) // -05:00 (EST)
        let zonedComponents = plainDateTime.foundation.components(in: chronoTimeZone)

        #expect(zonedComponents.timeZone?.secondsFromGMT() == -18000)
        #expect(zonedComponents.hour == 15)
    }

    @Test("PlainDateTimeFoundationTests: Outbound bridge proxy property (.chrono.plainDateTime)")
    func outboundBridgeProxy() throws {
        var components = Foundation.DateComponents()
        components.year = 1999
        components.month = 12
        components.day = 31
        components.hour = 23
        components.minute = 59
        components.second = 59
        components.nanosecond = 999_999_999

        let plainDateTime = try #require(components.chrono.plainDateTime)

        #expect(plainDateTime.year == 1999)
        #expect(plainDateTime.hour == 23)
        #expect(plainDateTime.nanosecond == 999_999_999)
    }
}
