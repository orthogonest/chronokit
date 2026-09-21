import ChronoCore
@testable import ChronoSystem
import Testing

struct ZonedDateTimeSystemTests {
    // MARK: - Initialization

    @Test("ZonedDateTimeSystemTests: Verifies that nowUTC always yields a zero offset")
    func nowUTC() {
        let utc: ZonedDateTime = .nowUTC
        let offset = utc.timeZone.offset(for: utc.instant)
        #expect(offset.seconds == 0)
        #expect(utc.timeZone == .utc)
    }

    @Test("ZonedDateTimeSystemTests: Verifies generic now(in:) works with various timezone types")
    func genericNow() {
        // Test with FixedOffset
        let jakartaTZ: TimeZone = .fixedOffset(.hours(7))
        let dtFixed: ZonedDateTime = .now(in: jakartaTZ)
        #expect(dtFixed.timeZone == jakartaTZ)

        // Test with System
        let dtSystem: ZonedDateTime = .now(in: .system)
        #expect(!dtSystem.timeZone.identifier.isEmpty)
    }

    @Test("ZonedDateTimeSystemTests: Precision consistency")
    func highPrecisionConsistency() {
        let instant1: Instant = .now
        let dt: ZonedDateTime = .now
        let instant2: Instant = .now

        // The datetime's instant must be bounded by the two snapshots
        #expect(dt.instant >= instant1)
        #expect(dt.instant <= instant2)
    }

    @Test("ZonedDateTimeSystemTests: Gap Initialization Clock")
    func highPrecisionGap() {
        let now: ZonedDateTime = .now
        let manualNow: ZonedDateTime = .now(in: .system)

        // Ensure they captured roughly the same time
        let diff = abs(now.instant.seconds - manualNow.instant.seconds)
        #expect(diff < 1)

        let fixed: ZonedDateTime = .now(in: .fixedOffset(.hours(7)))
        #expect(fixed.timeZone.offset(for: fixed.instant) == .hours(7))
    }

    @Test("ZonedDateTimeSystemTests: Timezone Identifier consistency")
    func identifierConsistency() {
        let sys = SystemTimeZone()
        let dt: ZonedDateTime = .now

        #expect(dt.timeZone.identifier == sys.identifier)
        #expect(!dt.timeZone.identifier.isEmpty)
    }

    @Test("ZonedDateTimeSystemTests: Parameterized Fixed Offsets", arguments: [
        0, 3600, -3600, 18000, -18000
    ])
    func parameterizedOffsets(seconds: Int) {
        let dt: ZonedDateTime = .now(in: .fixedOffset(seconds: seconds))
        #expect(dt.timeZone.offset(for: dt.instant) == .seconds(seconds))
    }

    @Test("ZonedDateTimeSystemTests: Extreme Offsets", arguments: [
        14 * 3600, // Max East
        -12 * 3600 // Max West
    ])
    func extremeOffsets(seconds: Int) {
        let dt: ZonedDateTime = .now(in: .fixedOffset(seconds: seconds))
        #expect(dt.timeZone.offset(for: dt.instant) == .seconds(seconds))
    }
}
