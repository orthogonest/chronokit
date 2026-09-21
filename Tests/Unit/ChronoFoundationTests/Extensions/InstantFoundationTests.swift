import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct InstantFoundationTests {
    // MARK: - From Foundation Tests

    @Test("InstantFoundationTests: Initialize from positive Date (Post-1970)")
    func initializeFromPositiveDate() {
        let interval: Foundation.TimeInterval = 1_790_000_000.123456789 // 21-09-2026 + fractional seconds
        let date = Foundation.Date(timeIntervalSince1970: interval)
        let instant = ChronoCore.Instant(foundation: date)

        #expect(instant.seconds == 1_790_000_000, "Seconds component should match exactly")

        let roundTripDate = Foundation.Date(chrono: instant)
        let delta = abs(roundTripDate.timeIntervalSince1970 - interval)

        #expect(
            delta < 1e-6,
            "The round-trip delta (\(delta)) must be within the physical limitations of a 64-bit Double"
        )
    }

    @Test("InstantFoundationTests: Initialize from negative Date (Pre-1970)")
    func initializeFromNegativeDate() {
        let interval: Foundation.TimeInterval = -100.3
        let date = Foundation.Date(timeIntervalSince1970: interval)

        let instant = ChronoCore.Instant(foundation: date)

        // seconds = Foundation.floor(-100.3) -> -101.0
        // fractional = -100.3 - (-101.0) -> 0.7
        // nanoseconds = round(0.7 * 1e9) -> 700_000_000

        #expect(
            instant.seconds == -101,
            "Floor logic on negative numbers should shift seconds toward negative infinity"
        )

        let roundTripDate = Foundation.Date(chrono: instant)
        let delta = abs(roundTripDate.timeIntervalSince1970 - interval)

        #expect(
            delta < 1e-6,
            "The round-trip delta (\(delta)) must be within the physical limitations of a 64-bit Double"
        )
    }

    @Test("InstantFoundationTests: Handle extreme floating-point rounding noise")
    func handleFloatingPointNoise() {
        let interval: Foundation.TimeInterval = 0.3
        let date = Foundation.Date(timeIntervalSince1970: interval)

        let instant = ChronoCore.Instant(foundation: date)

        #expect(instant.seconds == 0)

        let roundTripDate = Foundation.Date(chrono: instant)
        let delta = abs(roundTripDate.timeIntervalSince1970 - interval)

        #expect(
            delta < 1e-6,
            "The round-trip delta (\(delta)) must be within the physical limitations of a 64-bit Double"
        )
    }

    @Test("InstantFoundationTests: Handle exact Unix Epoch zero boundary")
    func unixEpochZeroBoundary() {
        let date = Foundation.Date(timeIntervalSince1970: 0)
        let instant = ChronoCore.Instant(foundation: date)

        #expect(instant.seconds == 0)
        #expect(instant.nanoseconds == 0)
    }
}

// MARK: - From ChronoKit Tests

extension InstantFoundationTests {
    @Test("InstantFoundationTests: Foundation.Date from ChronoCore.Instant")
    func dateFromChronoInstant() {
        let instant = ChronoCore.Instant(seconds: 5000, nanoseconds: 500_000_000)
        let date = Foundation.Date(chrono: instant)

        #expect(date.timeIntervalSince1970 == 5000.5, "Date representation in seconds should be perfectly combined")
    }
}

// MARK: - Proxy Bridge Tests

extension InstantFoundationTests {
    @Test("InstantFoundationTests: Inbound bridge proxy property (.foundation.date)")
    func inboundBridgeProxyProperty() {
        let instant = ChronoCore.Instant(seconds: 999_999, nanoseconds: 999)
        let date = instant.foundation.date

        let expectedInterval = 999_999.0 + (999.0 / ChronoCore.NanoSeconds.perSecondDouble)
        let delta = abs(date.timeIntervalSince1970 - expectedInterval)

        #expect(
            delta < 1e-6,
            "The inbound delta (\(delta)) must be within the physical limitations of a 64-bit Double"
        )
    }

    @Test("InstantFoundationTests: Outbound bridge proxy property (.chrono.instant)")
    func outboundBridgeProxyProperty() {
        let timeInterval = 8888.888888888
        let date = Foundation.Date(timeIntervalSince1970: timeInterval)
        let instant = date.chrono.instant

        #expect(instant.seconds == 8888)

        let delta = abs(instant.foundation.date.timeIntervalSince1970 - timeInterval)

        #expect(
            delta < 1e-6,
            "The outbound delta (\(delta)) must be within the physical limitations of a 64-bit Double"
        )
    }
}
