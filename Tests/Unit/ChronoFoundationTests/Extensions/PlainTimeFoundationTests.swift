import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct PlainTimeFoundationTests {
    // MARK: - From Foundadtion Tests

    @Test("PlainTimeTests: Initialize from valid Foundation.DateComponents with nanoseconds")
    func initializeFromValidComponentsWithNanos() throws {
        var components = Foundation.DateComponents()
        components.hour = 14
        components.minute = 30
        components.second = 15
        components.nanosecond = 123_456_789

        let plainTime: ChronoCore.PlainTime = try #require(PlainTime(foundation: components))

        #expect(plainTime.hour == 14, "Hour should match exactly")
        #expect(plainTime.minute == 30, "Minute should match exactly")
        #expect(plainTime.second == 15, "Second should match exactly")
        #expect(plainTime.nanosecond == 123_456_789, "Nanosecond should match exactly")
    }

    @Test("PlainTimeTests: Initialize from valid Foundation.DateComponents with missing nanoseconds")
    func initializeFromValidComponentsMissingNanos() throws {
        var components = Foundation.DateComponents()
        components.hour = 8
        components.minute = 15
        components.second = 0

        let plainTime: ChronoCore.PlainTime = try #require(PlainTime(foundation: components))

        #expect(plainTime.hour == 8)
        #expect(plainTime.minute == 15)
        #expect(plainTime.second == 0)
        #expect(plainTime.nanosecond == 0, "Nanosecond should fallback to 0 when missing from components")
    }

    @Test("PlainTimeTests: Initialize from incomplete Foundation.DateComponents")
    func initializeFromIncompleteComponents() {
        var components = Foundation.DateComponents()
        components.hour = 23

        let plainTime = ChronoCore.PlainTime(foundation: components)

        #expect(plainTime == nil, "Initialization must fail if core time components are missing")
    }
}

// MARK: - From ChronoKit Tests

extension PlainTimeFoundationTests {
    @Test("PlainTimeTests: Foundation.DateComponents from ChronoCore.PlainTime")
    func componentsFromChronoPlainTime() throws {
        let plainTime: ChronoCore.PlainTime = try #require(PlainTime(hour: 18, minute: 45, second: 30, nanosecond: 500))
        let components = Foundation.DateComponents(chrono: plainTime)

        #expect(components.hour == 18, "DateComponents hour should be populated correctly")
        #expect(components.minute == 45, "DateComponents minute should be populated correctly")
        #expect(components.second == 30, "DateComponents second should be populated correctly")
        #expect(components.nanosecond == 500, "DateComponents nanosecond should be populated correctly")

        #expect(components.year == nil)
        #expect(components.month == nil)
        #expect(components.day == nil)
    }
}

// MARK: - Proxy Bridge Property Tests

extension PlainTimeFoundationTests {
    @Test("PlainTimeTests: Inbound bridge proxy property (.foundation.components)")
    func inboundBridgeProxyProperty() throws {
        let plainTime: ChronoCore.PlainTime = try #require(PlainTime(hour: 12, minute: 0, second: 0, nanosecond: 0))
        let components = plainTime.foundation.components

        #expect(components.hour == 12)
        #expect(components.minute == 0)
        #expect(components.second == 0)
        #expect(components.nanosecond == 0)
    }

    @Test("PlainTimeTests: Outbound bridge proxy property (.chrono.plainTime)")
    func outboundBridgeProxyProperty() {
        var components = Foundation.DateComponents()
        components.hour = 5
        components.minute = 15
        components.second = 30

        let plainTime = components.chrono.plainTime

        #expect(plainTime != nil)
        #expect(plainTime?.hour == 5)
        #expect(plainTime?.minute == 15)
        #expect(plainTime?.second == 30)
        #expect(plainTime?.nanosecond == 0)
    }
}
