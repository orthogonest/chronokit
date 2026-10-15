@testable import ChronoSystem
import Foundation
import Testing

struct FNV1aTests {
    @Test("FNV1aTests: Verify deterministic output stability across identical tokens")
    func deterministicStability() {
        let input = "en_US"

        let firstRun = FNV1a.hash32(input)
        let secondRun = FNV1a.hash32(input)
        let thirdRun = FNV1a.hash32(input)

        #expect(firstRun == secondRun, "Hashing must be pure and deterministic across identical string tokens.")
        #expect(firstRun == thirdRun, "Hashing consistency failed over multiple invocation lifecycles.")

        // Cross-reference with verified baseline FNV-1a standard values
        // String "en_US" UTF-8 bytes: [0x65, 0x6E, 0x5F, 0x55, 0x53]
        // Standard FNV-1a 32-bit computation for "en_US" yields exactly 2345279367 (0x8BCA_1F87)
        #expect(firstRun == 0x8BCA_1F87, "Hash output value drifts from verified formal FNV-1a baseline limits.")
    }

    @Test("FNV1aTests: Verify string and raw byte sequence compatibility layout symmetry")
    func sequenceSymmetry() {
        let targetString = "id_ID"
        let rawBytesRepresentation: [UInt8] = [0x69, 0x64, 0x5F, 0x49, 0x44] // UTF-8 view of "id_ID"

        let hashFromString = FNV1a.hash32(targetString)
        let hashFromBytesSequence = FNV1a.hash32(rawBytesRepresentation)

        #expect(hashFromString == hashFromBytesSequence, "Symmetry error: String hashing drifts from direct byte sequence processing.")
    }

    @Test("FNV1aTests: Verify avalanche effect and sensitivity mapping against collision indicators")
    func avalancheEffectAndSensitivity() {
        let localeA = "en_US"
        let localeB = "en_UK"
        let localeC = "en_GB"

        let hashA = FNV1a.hash32(localeA)
        let hashB = FNV1a.hash32(localeB)
        let hashC = FNV1a.hash32(localeC)

        #expect(hashA != hashB, "Collision Found: Single character modifications must sling bits to unique spaces.")
        #expect(hashA != hashC, "Collision Found: Distant geographical locale identifiers produced duplicate integer hashes.")
        #expect(hashB != hashC, "Collision Found: Similar structural tokens failed to separate boundaries cleanly.")
    }

    @Test("FNV1aTests: Verify boundary checks for completely empty string inputs")
    func emptyStringThreshold() {
        let emptyHash = FNV1a.hash32("")

        // An empty collection should return the exact base offset metric (offset32 value) without crashing
        #expect(emptyHash == 0x811C_9DC5, "Empty strings must return the baseline initial offset value (0x811C9DC5).")
    }
}
