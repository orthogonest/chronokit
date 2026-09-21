import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct PlainDateFoundationTests {
    // MARK: - From Foundadtion Tests

    @Test("PlainDateTests: Initialize from valid Foundation.DateComponents")
    func initializeFromValidComponents() {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 21

        let plainDate = ChronoCore.PlainDate(foundation: components)

        #expect(plainDate != nil, "Initialization should succeed with valid components")
        #expect(plainDate?.year == 2026, "Year should match exactly")
        #expect(plainDate?.month == 9, "Month should match exactly")
        #expect(plainDate?.day == 21, "Day should match exactly")
    }

    @Test("PlainDateTests: Initialize from incomplete Foundation.DateComponents")
    func initializeFromIncompleteComponents() {
        var components = Foundation.DateComponents()
        components.year = 2026
        components.month = 9

        let plainDate = ChronoCore.PlainDate(foundation: components)

        #expect(plainDate == nil, "Initialization must fail if any core date component is missing")
    }
}

// MARK: - From ChronoKit Tests

extension PlainDateFoundationTests {
    @Test("PlainDateTests: Foundation.DateComponents from ChronoCore.PlainDate")
    func componentsFromChronoPlainDate() throws {
        let plainDate: ChronoCore.PlainDate = try #require(PlainDate(year: 2024, month: 2, day: 29)) // Leap year
        let components = Foundation.DateComponents(chrono: plainDate)

        #expect(components.year == 2024, "DateComponents year should be populated correctly")
        #expect(components.month == 2, "DateComponents month should be populated correctly")
        #expect(components.day == 29, "DateComponents day should be populated correctly")
        #expect(components.hour == nil)
        #expect(components.minute == nil)
        #expect(components.second == nil)
        #expect(components.nanosecond == nil)
    }
}

// MARK: - Proxy Bridge Property Tests

extension PlainDateFoundationTests {
    @Test("PlainDateTests: Inbound bridge proxy property (.foundation.components)")
    func inboundBridgeProxyProperty() {
        let plainDate = ChronoCore.PlainDate(year: 1970, month: 1, day: 1)
        let components = plainDate?.foundation.components

        #expect(components?.year == 1970)
        #expect(components?.month == 1)
        #expect(components?.day == 1)
    }

    @Test("PlainDateTests: Outbound bridge proxy property (.chrono.plainDate)")
    func outboundBridgeProxyProperty() {
        var components = Foundation.DateComponents()
        components.year = 2000
        components.month = 12
        components.day = 25

        let plainDate = components.chrono.plainDate

        #expect(plainDate != nil)
        #expect(plainDate?.year == 2000)
        #expect(plainDate?.month == 12)
        #expect(plainDate?.day == 25)
    }
}
