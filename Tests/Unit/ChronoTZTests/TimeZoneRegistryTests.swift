@testable import ChronoSystem
@testable import ChronoTZ
import Testing

struct TimeZoneRegistryTests {
    @Test("TimeZoneRegistryTests: Fails on invalid magic")
    func invalidHeader() throws {
        #expect(throws: BinaryError.prematureEOF) {
            _ = try TimeZoneRegistry(bytes: [])
        }
    }

    @Test("TimeZoneRegistryTests: Successfully loads and retrieves entry")
    func successPath() throws {
        let targetName = "UTC"
        let payload = "PAYLOAD_DATA_16B"
        let mockBytes = try createMockTZDB(entryName: targetName, payload: payload)

        let registry = try TimeZoneRegistry(bytes: mockBytes)

        // Test getEntry
        let entry = try #require(registry.getEntry(named: targetName), "Should find the entry")
        #expect(entry.nameString == targetName)

        // Test getPayload
        let buffer = try registry.getPayload(for: entry)
        let payloadString = String(decoding: buffer, as: UTF8.self)
        #expect(payloadString == payload)
    }
}

// MARK: - Helpers

extension TimeZoneRegistryTests {
    private func createMockTZDB(
        entryName: String,
        payload: String
    ) throws -> [UInt8] {
        var bytes: [UInt8] = []

        // ---- Write Header ----
        // Magic: TZDB (4 bytes)
        bytes.append(contentsOf: [0x54, 0x5A, 0x44, 0x42])
        // Version: 1 (4 bytes, BigEndian)
        bytes.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })
        // Count: 1 (4 bytes, BigEndian)
        bytes.append(contentsOf: withUnsafeBytes(of: UInt32(1).bigEndian) { Array($0) })

        // ---- Write Index Entry ----
        // Name: FixedName (64 bytes)
        var nameBytes = Array(entryName.utf8)
        nameBytes.append(contentsOf: Array(repeating: UInt8(0), count: FixedName.size - nameBytes.count))
        bytes.append(contentsOf: nameBytes)

        // Offset: 4 bytes, BigEndian
        // Header (12 bytes) + Entry (72 bytes) = 84 bytes offset
        bytes.append(contentsOf: withUnsafeBytes(of: UInt32(84).bigEndian) { Array($0) })
        // Size: 4 bytes, BigEndian
        bytes.append(contentsOf: withUnsafeBytes(of: UInt32(payload.utf8.count).bigEndian) { Array($0) })

        // ---- Write Payload ----
        bytes.append(contentsOf: payload.utf8)

        return bytes
    }
}
