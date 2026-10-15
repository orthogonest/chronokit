@testable import ChronoLocale
import Foundation
import Testing

struct BinarySerializerTests {
    @Test("BinarySerializerTests: Verify raw binary serialization matches exact mathematical block footprints and offsets")
    func binarySerializationLayoutIntegrity() {
        let mockHeader = LocaleHeaderLayout(
            magic: .cldb,
            version: 1,
            localeCount: 1,
            stringPoolOffset: 16 + 8 + 760 // header(16) + 1 node(8) + 1 block(760) = 784
        )

        let mockIndexNode = LocaleIndexNodeLayout(
            localeHash: 0x1234_5678,
            blockOffset: 24 // starts exactly after header(16) + indexTable(8)
        )

        // Zero-initialize the 760-byte block using a mutable pointer buffer layer
        var mockBlock = LocaleBlockLayout(
            dateFormatFull: 0,
            dateFormatLong: 0,
            dateFormatMedium: 0,
            dateFormatShort: 0,
            timeFormatFull: 0,
            timeFormatLong: 0,
            timeFormatMedium: 0,
            timeFormatShort: 0,
            dateTimeFormatFull: 0,
            dateTimeFormatLong: 0,
            dateTimeFormatMedium: 0,
            dateTimeFormatShort: 0,
            monthsFormatWide: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            monthsFormatAbbreviated: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            monthsFormatNarrow: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            monthsStandaloneWide: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            monthsStandaloneAbbreviated: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            monthsStandaloneNarrow: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            daysFormatWide: (0, 0, 0, 0, 0, 0, 0),
            daysFormatAbbreviated: (0, 0, 0, 0, 0, 0, 0),
            daysFormatNarrow: (0, 0, 0, 0, 0, 0, 0),
            daysFormatShort: (0, 0, 0, 0, 0, 0, 0),
            daysStandaloneWide: (0, 0, 0, 0, 0, 0, 0),
            daysStandaloneAbbreviated: (0, 0, 0, 0, 0, 0, 0),
            daysStandaloneNarrow: (0, 0, 0, 0, 0, 0, 0),
            daysStandaloneShort: (0, 0, 0, 0, 0, 0, 0),
            quartersFormatWide: (0, 0, 0, 0),
            quartersFormatAbbreviated: (0, 0, 0, 0),
            quartersFormatNarrow: (0, 0, 0, 0),
            quartersStandaloneWide: (0, 0, 0, 0),
            quartersStandaloneAbbreviated: (0, 0, 0, 0),
            quartersStandaloneNarrow: (0, 0, 0, 0),
            dayPeriodsFormatWide: (0, 0),
            dayPeriodsFormatAbbreviated: (0, 0),
            dayPeriodsFormatNarrow: (0, 0),
            dayPeriodsStandaloneWide: (0, 0),
            dayPeriodsStandaloneAbbreviated: (0, 0),
            dayPeriodsStandaloneNarrow: (0, 0),
            erasWide: (0, 0),
            erasAbbreviated: (0, 0),
            erasNarrow: (0, 0),
            dateSkeletonFull: 0,
            dateSkeletonLong: 0,
            dateSkeletonMedium: 0,
            dateSkeletonShort: 0,
            timeSkeletonFull: 0,
            timeSkeletonLong: 0,
            timeSkeletonMedium: 0,
            timeSkeletonShort: 0
        )

        // Inject a distinct control value inside the block to track offset positions post-serialization
        // (Modifying timeSkeletonShort, located at the very last UInt32 register position)
        withUnsafeMutableBytes(of: &mockBlock) { ptr in
            ptr.storeBytes(of: UInt32(0xDEAD_BEEF), toByteOffset: 756, as: UInt32.self)
        }

        let mockStringPoolBytes: [UInt8] = [0x41, 0x42, 0x43, 0x44] // "ABCD" (4 bytes)

        let mockLayout = CLDBLayout(
            header: mockHeader,
            indexes: [mockIndexNode],
            blocks: [mockBlock],
            stringPool: mockStringPoolBytes
        )

        // Trigger the serialization extraction pipeline
        let serializedBytes = BinarySerializer.serialize(mockLayout)

        // Mathematical Verification: Assert that total footprint matches expected dimensions exactly
        // 16 (Header) + 8 (Index Table) + 760 (Locale Block) + 4 (String Pool) = 788 bytes
        let expectedTotalBytesCount = 16 + 8 + 760 + 4
        #expect(serializedBytes.count == expectedTotalBytesCount, "Monolithic byte array size drifts from strict structural boundaries.")

        // Memory Mapping Verification: Use pointers to verify bitwise data compliance
        serializedBytes.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else {
                Issue.record("Failed to acquire raw memory base address pointer view.")
                return
            }

            // Verify Global Header Segement
            let loadedHeader = baseAddress.load(as: LocaleHeaderLayout.self)
            #expect(loadedHeader.magic == .cldb, "Serialization error: First 4 bytes must match 'CLDB' token layout.")
            #expect(loadedHeader.stringPoolOffset == 784, "String pool pointer offset configuration corrupt.")

            // Verify Index Table Node Segment (Offset 16 bytes from base address)
            let loadedIndexNode = baseAddress.load(fromByteOffset: 16, as: LocaleIndexNodeLayout.self)
            #expect(loadedIndexNode.localeHash == 0x1234_5678, "Index Node identifier token corruption.")
            #expect(loadedIndexNode.blockOffset == 24, "Index Node block offset address calculation failed.")

            // Verify Data Block Field Segment (Offset 24 bytes from base address)
            // Extract our pre-calculated control marker located at the very end of the 760-byte block block structure
            // Absolute Offset: 24 (Block Base Offset) + 756 (Field Offset) = 780 bytes
            let loadedControlMarker = baseAddress.load(fromByteOffset: 780, as: UInt32.self)
            #expect(loadedControlMarker == 0xDEAD_BEEF, "Data Block structure fields mapping misalignment error.")

            // Verify Trailing String Pool Segment (Offset 784 bytes from base address)
            let stringPoolPointer = baseAddress.advanced(by: 784).assumingMemoryBound(to: UInt8.self)
            #expect(stringPoolPointer.pointee == 0x41, "String Pool character data corrupted or shifted.")
            #expect(stringPoolPointer.advanced(by: 3).pointee == 0x44, "String Pool tail element mapping drift.")
        }
    }
}
