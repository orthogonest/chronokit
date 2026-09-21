import ChronoCore
import ChronoSystem
@testable import ChronoTZ
import Testing

struct IANARegistryTests {
    static var allZoneNames: [String] {
        do {
            let registry = try TimeZoneRegistry(bytes: PackageResources.iana_tzdb)
            return registry.indexNames
        } catch {
            print("DEBUG: Could not load tzdb: \(error)")
            return []
        }
    }

    @Test("IANARegistryTests: Verify DB Magic Bytes")
    func verifyMagicHeader() {
        let bytes = PackageResources.iana_tzdb
        #expect(bytes.count > 4, "The compiled database file is empty or truncated.")

        let headerPrefix = String(decoding: bytes.prefix(4), as: UTF8.self)
        #expect(
            headerPrefix == "TZDB",
            "Invalid database format. Expected header prefix 'TZif', but found '\(headerPrefix)'"
        )
    }

    @Test("IANARegistryTests: Registry integrity", arguments: allZoneNames)
    func allZones(zoneName: String) throws {
        let tz = try IANAProvider.shared.timeZone(named: zoneName)
        #expect(tz.identifier == zoneName)
        #expect(!tz.payload.types.isEmpty)

        let now: Instant = .now
        let offset = tz.offset(for: now)
        let maxReasonableOffset: Int64 = 14 * Seconds.perHour64
        #expect(
            abs(offset.seconds) <= maxReasonableOffset,
            "Offset for \(zoneName) is suspiciously large: \(offset.seconds)"
        )

        let historicalInstant = Instant(seconds: 157_770_000) // 01-01-1975
        let historicalOffset = tz.offset(for: historicalInstant)
        #expect(
            abs(historicalOffset.seconds) <= maxReasonableOffset,
            "Historical offset for \(zoneName) is suspiciously large: \(historicalOffset.seconds)"
        )
    }

    @Test("IANARegistryTests: Registry completeness check")
    func registryCompleteness() {
        let zones = IANARegistryTests.allZoneNames
        print("DEBUG: Verified \(zones.count) time zones in registry.")

        // Ensure we haven't lost a significant chunk of the database
        // (590 is a safe lower bound for modern IANA releases)
        #expect(
            zones.count >= 590,
            "Registry count dropped significantly: found \(zones.count)"
        )
    }

    @Test("IANARegistryTests: Complex DST Regression Checks")
    func verifyKnownTimezoneTransitions() throws {
        // Test a zone notorious for complex historical shifts (London GMT -> BST)
        let london = try IANAProvider.shared.timeZone(named: "Europe/London")

        let winterLondon = Instant(seconds: 1_767_225_600)
        #expect(london.offset(for: winterLondon).seconds == 0, "Jan 1, 2026: Should be GMT (0 offset)")

        let summerLondon = Instant(seconds: 1_782_864_000)
        #expect(london.offset(for: summerLondon).seconds == 3600, "Jul 1, 2026: Should be BST (+3600 seconds offset)")

        let kiritimati = try IANAProvider.shared.timeZone(named: "Pacific/Kiritimati")
        let kiritimatiOffset = kiritimati.offset(for: Instant.now)
        #expect(kiritimatiOffset.seconds == 14 * Seconds.perHour64, "Line Islands should maintain +14 UTC baseline")
    }
}
