@testable import ChronoLocale
import Foundation
import Testing

struct StringPoolBuilderTests {
    @Test("StringPoolBuilderTests: Verify string deduplication and exact bit-packing 24:8 mechanics")
    func stringDeduplicationAndBitPacking() {
        var builder = StringPoolBuilder()

        let token = "yyyy-MM-dd"
        let tokenLength = UInt32(token.utf8.count) // 10 bytes

        // First insert: should append new bytes and return standard packed coordinates
        let packedValue1 = builder.insert(token)

        // Unpack manually via 24:8 bitwise masks
        let offset1 = packedValue1 >> 8
        let length1 = packedValue1 & 0xFF

        #expect(offset1 == 0, "Initial token string should be allocated at base offset 0.")
        #expect(length1 == tokenLength, "Decoded length matrix drifts from token UTF-8 byte count.")
        #expect(builder.count == 10, "String pool storage byte alignment failed on first insertion.")

        // Second insert (Deduplication Path): should return the exact same packed configuration key
        let packedValue2 = builder.insert(token)

        let offset2 = packedValue2 >> 8
        let length2 = packedValue2 & 0xFF

        #expect(packedValue1 == packedValue2, "Deduplication failed: identical tokens must map to identical layout integers.")
        #expect(offset2 == 0, "Deduplicated layout key points to incorrect pool coordinates.")
        #expect(length2 == tokenLength, "Deduplicated string footprint length tracking error.")
        #expect(builder.count == 10, "Deduplication leaked memory; string pool size must not grow for identical elements.")

        // Third insert with distinct token: should position data chronologically after the first entry
        let secondToken = "HH:mm" // 5 bytes
        let packedValue3 = builder.insert(secondToken)

        let offset3 = packedValue3 >> 8
        let length3 = packedValue3 & 0xFF

        #expect(offset3 == 10, "Secondary allocation must start precisely at the previous accumulation peak boundary.")
        #expect(length3 == 5, "Footprint evaluation failed for intermediate token string entries.")
        #expect(builder.count == 15, "Accumulated pool size footprint verification mismatch.")
    }

    @Test("StringPoolBuilderTests: Verify safe fixed tuple conversion utilities (Months, Days, Quarters, Periods)")
    func tupleCollectionInsertionUtilities() {
        var builder = StringPoolBuilder()

        // Verify 12-Month fixed layout unpacking sequence
        let mockMonths = (1 ... 12).map { "Month-\($0)" }
        let packedMonths = builder.insert12(months: mockMonths)

        // Validate index boundary sampling via bitwise unpack
        let month1Offset = packedMonths.0 >> 8
        let month1Length = packedMonths.0 & 0xFF
        #expect(month1Offset == 0, "Chronological collection layout allocation error on root position.")
        #expect(month1Length == 7, "Length evaluation error on string tuple compilation bounds.")

        // Verify 7-Day sequence consistency mapping
        let mockDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let packedDays = builder.insert7(days: mockDays)

        let sunLength = packedDays.0 & 0xFF
        #expect(sunLength == 3, "Day identification string bounds track error inside structural sequence array.")

        // Verify 4-Quarter structural isolation bounds
        let mockQuarters = ["Q1", "Q2", "Q3", "Q4"]
        let packedQuarters = builder.insert4(quarters: mockQuarters)

        let q4Offset = packedQuarters.3 >> 8
        let q4Length = packedQuarters.3 & 0xFF
        #expect(q4Length == 2, "Quarter component width dimension track failure.")
        #expect(q4Offset > 0, "Sequential tuple entries must chain allocation layout indices consecutively.")

        // Verify 2-Item Day Periods (AM/PM boundary) array symmetry
        let packedPeriods = builder.insert2(periods: ["AM", "PM"])
        #expect((packedPeriods.0 & 0xFF) == 2, "AM bit representation failed initialization validation.")
        #expect((packedPeriods.1 & 0xFF) == 2, "PM bit representation failed initialization validation.")
    }

    @Test("StringPoolBuilderTests: Verify 4-byte structural hardware alignment and padding generation markers")
    func hardwarePaddedAlignmentOutput() {
        var builder = StringPoolBuilder()

        // Insert a 7-byte string (Unaligned payload baseline: 7 is not divisible by 4)
        _ = builder.insert("Unalign")
        #expect(builder.count == 7, "Raw unaligned accumulation mismatch.")

        // Trigger structural finalization pass to inject alignment padding bytes
        let finalizedBytes = builder.build()

        // Enforce safe 4-byte boundaries required to protect pointer casting routines on ARM64 hardware
        #expect(finalizedBytes.count % 4 == 0, "Hardware alignment error: final stream byte length must be a multiple of 4.")
        #expect(finalizedBytes.count == 8, "Padding buffer extraction failure: 7 bytes must be padded with 1 null byte to yield 8.")

        // Ensure that injected padding characters are standard safe 0x00 null boundaries
        #expect(finalizedBytes[7] == 0, "Unaligned tail pointers must be safely bounded using empty null bits.")
    }
}
