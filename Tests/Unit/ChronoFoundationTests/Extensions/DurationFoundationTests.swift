import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct DurationFoundationTests {
    // MARK: - From Foundation Tests

    @Test("DurationFoundationTests: Initialize from positive TimeInterval")
    func initializeFromPositiveTimeInterval() {
        let interval: TimeInterval = 123.456789123
        let duration = ChronoCore.Duration(foundation: interval)

        #expect(duration.seconds == 123, "Seconds should match the integer part")
        #expect(duration.nanoseconds == 456_789_123, "Nanoseconds should capture the fractional part precisely")
    }

    @Test("DurationFoundationTests: Initialize from negative TimeInterval")
    func initializeFromNegativeTimeInterval() {
        let interval: TimeInterval = -45.678912345
        let duration = ChronoCore.Duration(foundation: interval)

        let reConvertedInterval = TimeInterval(chrono: duration)
        #expect(
            abs(reConvertedInterval - interval) < 1e-9,
            "Negative duration should retain its total mathematical value across conversion"
        )
    }

    @Test("DurationFoundationTests: Initialize from TimeInterval with extreme rounding noise")
    func initializeFromTimeIntervalWithNoise() {
        let interval: TimeInterval = 0.3
        let duration = ChronoCore.Duration(foundation: interval)

        #expect(duration.seconds == 0)
        #expect(duration.nanoseconds == 300_000_000, "Round logic must eliminate floating point noise for 0.3 seconds")
    }

    @Test("DurationFoundationTests: Initialize from Swift.Duration")
    func initializeFromSwiftDuration() {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let swiftDuration: Swift.Duration = .seconds(10) + .nanoseconds(500)
            let duration = ChronoCore.Duration(foundation: swiftDuration)

            #expect(duration.seconds == 10)
            #expect(duration.nanoseconds == 500)
        }
    }
}

// MARK: - From ChronoKit Tests

extension DurationFoundationTests {
    @Test("DurationFoundationTests: TimeInterval from ChronoCore.Duration")
    func timeIntervalFromChronoDuration() {
        let duration = ChronoCore.Duration(seconds: 5, nanoseconds: 500_000_000)
        let interval = Foundation.TimeInterval(chrono: duration)

        #expect(interval == 5.5, "TimeInterval should be correct scale in seconds")
    }

    @Test("DurationFoundationTests: Swift.Duration from ChronoCore.Duration")
    func swiftDurationFromChronoDuration() {
        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let duration = ChronoCore.Duration(seconds: 3600, nanoseconds: 123_456_789)
            let swiftDuration = Swift.Duration(chrono: duration)

            #expect(swiftDuration.components.seconds == 3600)
            #expect(swiftDuration.components.attoseconds == 123_456_789 * AttoSeconds.perNanoSecond64)
        }
    }
}

// MARK: - Proxy Bridge Tests

extension DurationFoundationTests {
    @Test("DurationFoundationTests: Inbound bridge calls (.foundation)")
    func inboundBridgeCalls() {
        let duration = ChronoCore.Duration(seconds: 8, nanoseconds: 250_000_000)

        #expect(duration.foundation.timeInterval == 8.25)

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let swiftDuration = duration.foundation.duration
            #expect(swiftDuration.components.seconds == 8)
        }
    }

    @Test("DurationFoundationTests: Outbound bridge calls (.chrono)")
    func outboundBridgeCalls() {
        let interval: Foundation.TimeInterval = 15.75
        let durationFromInterval = interval.chrono.duration

        #expect(durationFromInterval.seconds == 15)
        #expect(durationFromInterval.nanoseconds == 750_000_000)

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            let swiftDuration: Swift.Duration = .seconds(2) + .nanoseconds(100)
            let durationFromSwift = swiftDuration.chrono.duration

            #expect(durationFromSwift.seconds == 2)
            #expect(durationFromSwift.nanoseconds == 100)
        }
    }
}
