import ChronoCore
import ChronoTZ
import Testing

struct ZonedDateTimeIntegrationTests {
    @Test("ZonedDateTimeIntegrationTests: Initializes with Instant and valid Zone")
    func initFromInstantAndZone() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)
        let zoneName = "UTC" // Assuming "UTC" is in your shared DB

        let dt = try ZonedDateTime(instant: instant, timeZone: zoneName)

        #expect(dt.timeZone.identifier == "UTC")
        #expect(dt.instant == instant)
    }

    @Test("ZonedDateTimeIntegrationTests: Throws error for invalid zone name")
    func initThrowsForUnknownZone() throws {
        let instant = Instant(seconds: 0, nanoseconds: 0)

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try ZonedDateTime(instant: instant, timeZone: "Invalid/Zone")
        }
    }

    @Test("ZonedDateTimeIntegrationTests: now(in:) creates valid object")
    func nowInZone() throws {
        let dt = try ZonedDateTime.now(in: "UTC")

        #expect(dt.timeZone.identifier == "UTC", "Timezone should match")

        // We verify the instant is "recent" (within a 1-second margin of error)
        let now: Instant = .now
        let diff = abs(dt.instant.seconds - now.seconds)
        #expect(diff < 1, "Expected time to be roughly 'now', got difference of \(diff)s")
    }

    @Test("ZonedDateTimeIntegrationTests: now in WIB")
    func nowInJakarta() throws {
        let dt = try ZonedDateTime.now(in: "Asia/Jakarta")

        #expect(dt.timeZone.identifier == "Asia/Jakarta", "Timezone should match")

        // We verify the instant is "recent" (within a 1-second margin of error)
        let now: Instant = .now
        let diff = abs(dt.instant.seconds - now.seconds)
        #expect(diff < 1, "Expected time to be roughly 'now', got difference of \(diff)s")
    }
}
