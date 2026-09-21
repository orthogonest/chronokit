import ChronoCore
import ChronoMath
import ChronoSystem
import ChronoTZ
import Testing

struct InstantTZIntegrationTests {
    @Test("InstantTZIntegrationTests: plainDateTime(in:) works with valid zone")
    func plainDateTimeConversion() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)

        let zone = "UTC"

        let plain = try instant.plainDateTime(in: zone)

        // Ensure conversion didn't return an empty/error state
        // You might add specific property checks here depending on PlainDateTime's API
        #expect(plain.year == 2023)
        #expect(plain.month == 11)
        #expect(plain.day == 14)
        #expect(plain.hour == 22)
        #expect(plain.minute == 13)
        #expect(plain.second == 20)
    }

    @Test("InstantTZIntegrationTests: dateTime(in:) assigns correct timezone")
    func dateTimeConversion() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)
        let zone = "Asia/Jakarta"

        let dt = try instant.zonedDateTime(in: zone)

        #expect(dt.timeZone.identifier == "Asia/Jakarta")
        #expect(dt.instant == instant)
    }

    @Test("InstantTZIntegrationTests: Injection of custom provider works")
    func customProviderInjection() throws {
        let instant = Instant(seconds: 1_700_000_000, nanoseconds: 0)

        #expect(throws: TZDBError.invalidHeader) {
            let dummyBytes: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
            let provider = try IANAProvider(bytes: dummyBytes)
            _ = try instant.zonedDateTime(in: "UTC", provider: provider)
        }
    }

    @Test("InstantTZIntegrationTests: Throws error for invalid zone name")
    func initThrowsForUnknownZone() throws {
        let instant = Instant(seconds: 0, nanoseconds: 0)

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            _ = try instant.zonedDateTime(in: "Invalid/Zone")
        }
    }
}
