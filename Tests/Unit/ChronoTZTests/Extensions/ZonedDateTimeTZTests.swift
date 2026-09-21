import ChronoCore
import ChronoSystem
@testable import ChronoTZ
import Testing

struct ZonedDateTimeTZTests {
    @Test("ZonedDateTimeTZTests: Initializer uses injected provider")
    func initializerUsesInjectedProvider() throws {
        // Create data payload
        let types = try [TZDBTypeDefinition(offset: 3600, isDST: 0)]
        let transitions = try [TZDBTransition(unixTime: 1000, typeIndex: 0)]
        let payload = try TZDBDataPayload.makePayload(transitions: transitions, types: types)

        // Create timezone provider
        let mock = MockTimeZoneProvider()
        let tzName = "Mock/Zone"
        let tz = TimeZoneInfo(identifier: tzName, payload: payload)
        mock.insertZones(tzName, tz: tz)

        let instant = Instant(seconds: 0, nanoseconds: 0)
        let dt = try ZonedDateTime(instant: instant, timeZone: tzName, provider: mock)

        #expect(dt.timeZone.identifier == tzName)
    }

    @Test("ZonedDateTimeTZTests: Initializer propagates provider errors")
    func initializerPropagatesErrors() throws {
        let failingMock = MockTimeZoneProvider()

        #expect(throws: TimeZoneError.zoneNotFound("Bad/Zone")) {
            _ = try ZonedDateTime(instant: .now, timeZone: "Bad/Zone", provider: failingMock)
        }
    }
}
