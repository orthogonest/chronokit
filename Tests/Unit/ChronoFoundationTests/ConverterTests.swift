import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct ConverterTests {
    @Test("ConverterTests: ChronoCore types adopt ChronoToFoundation and provide foundation proxy")
    func inboundBridgeStorage() {
        let date = ChronoCore.PlainDate(daysSinceEpoch: 0)
        let time = ChronoCore.PlainTime(nanosecondsSinceMidnight: 0)
        let dateTime = ChronoCore.PlainDateTime(date: date, time: time)
        let instant = ChronoCore.Instant(seconds: 0, nanoseconds: 0)
        let timeZone = ChronoCore.TimeZone(ChronoCore.FixedOffset.utc)
        let zonedDateTime = ChronoCore.ZonedDateTime(instant: instant, timeZone: timeZone)

        // Memastikan kompilasi dan jenis tipe proxy inbound benar
        #expect(type(of: date.foundation) == FoundationInboundBridge<ChronoCore.PlainDate>.self)
        #expect(type(of: time.foundation) == FoundationInboundBridge<ChronoCore.PlainTime>.self)
        #expect(type(of: dateTime.foundation) == FoundationInboundBridge<ChronoCore.PlainDateTime>.self)
        #expect(type(of: instant.foundation) == FoundationInboundBridge<ChronoCore.Instant>.self)
        #expect(type(of: timeZone.foundation) == FoundationInboundBridge<ChronoCore.TimeZone>.self)
        #expect(type(of: zonedDateTime.foundation) == FoundationInboundBridge<ChronoCore.ZonedDateTime>.self)
    }

    @Test("ConverterTests: Foundation and Swift types adopt FoundationToChrono and provide chrono proxy")
    func foundationAndSwiftTypesAdaptation() {
        let components = Foundation.DateComponents()
        let date = Foundation.Date()
        let interval = Foundation.TimeInterval(1.0)
        let timeZone = Foundation.TimeZone.current

        // Memastikan kompilasi dan jenis tipe proxy outbound benar
        #expect(type(of: components.chrono) == FoundationOutboundBridge<Foundation.DateComponents>.self)
        #expect(type(of: date.chrono) == FoundationOutboundBridge<Foundation.Date>.self)
        #expect(type(of: interval.chrono) == FoundationOutboundBridge<Foundation.TimeInterval>.self)
        #expect(type(of: timeZone.chrono) == FoundationOutboundBridge<Foundation.TimeZone>.self)

        if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
            testSwiftDurationExtension()
        }
    }

    /// Helper function terisolasi untuk menghindari isu kompilasi versi OS lama pada Swift.Duration
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    private func testSwiftDurationExtension() {
        let swiftDuration = Swift.Duration.seconds(1)
        #expect(type(of: swiftDuration.chrono) == FoundationOutboundBridge<Swift.Duration>.self)
    }
}
