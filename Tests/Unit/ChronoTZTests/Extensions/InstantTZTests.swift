import ChronoCore
@testable import ChronoTZ
import Testing

struct InstantTZTests {
    let instant = Instant(seconds: 1_713_926_400)

    @Test("InstantTZTests: PlainDateTime conversion succeeds with valid provider")
    func plainDateTimeSuccess() throws {
        // Create data payload
        let types = try [TZDBTypeDefinition(offset: 0, isDST: 0)]
        let transitions = try [TZDBTransition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDBDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        _ = try instant.plainDateTime(in: tzName, provider: mock)
    }

    @Test("InstantTZTests: DateTime conversion succeeds with valid provider")
    func dateTimeSuccess() throws {
        // Create data payload
        let types = try [TZDBTypeDefinition(offset: 0, isDST: 0)]
        let transitions = try [TZDBTransition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDBDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "UTC"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        let result = try instant.zonedDateTime(in: tzName, provider: mock)

        #expect(result.timeZone.identifier == tzName)
    }

    @Test("InstantTZTests: Methods throw error when TimeZone is not found")
    func conversionThrowsOnInvalidZone() throws {
        let mock = MockTimeZoneProvider()

        #expect(throws: (any Error).self) {
            try instant.plainDateTime(in: "Invalid/Zone", provider: mock)
        }

        #expect(throws: (any Error).self) {
            try instant.zonedDateTime(in: "Invalid/Zone", provider: mock)
        }
    }
}
