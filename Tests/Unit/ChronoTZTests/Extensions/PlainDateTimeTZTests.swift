import ChronoCore
@testable import ChronoTZ
import Testing

struct PlainDateTimeTZTests {
    let sample = PlainDateTime(year: 2026, month: 4, day: 24, hour: 10, minute: 0, second: 0)

    @Test("PlainDateTimeTZTests: instant() conversion succeeds with valid provider")
    func instantConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = try TimeZoneInfo(identifier: tzName, payload: TZDBDataPayload.makePayload())
        mock.insertZones(tzName, tz: tz)

        let plainDateTime = try #require(sample, "Sample plain date time should valid")
        let result = try plainDateTime.instant(in: tzName, provider: mock)

        #expect(result.seconds >= 0)
    }

    @Test("PlainDateTimeTZTests: dateTime() conversion succeeds with valid provider")
    func dateTimeConversionSuccess() throws {
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = try TimeZoneInfo(identifier: tzName, payload: TZDBDataPayload.makePayload())
        mock.insertZones(tzName, tz: tz)

        let plainDateTime = try #require(sample, "Sample plain date time should valid")
        let result = try plainDateTime.zonedDateTime(timeZone: tzName, provider: mock)

        #expect(result.timeZone.identifier == tzName)
    }

    @Test("PlainDateTimeTZTests: throws error when TimeZone name is invalid")
    func conversionThrowsOnInvalidZone() throws {
        let mock = MockTimeZoneProvider()
        let plainDateTime = try #require(sample, "Sample plain date time should valid")

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try plainDateTime.instant(in: "Invalid/Zone", provider: mock)
        }

        #expect(throws: TimeZoneError.zoneNotFound("Invalid/Zone")) {
            try plainDateTime.zonedDateTime(timeZone: "Invalid/Zone", provider: mock)
        }
    }
}
