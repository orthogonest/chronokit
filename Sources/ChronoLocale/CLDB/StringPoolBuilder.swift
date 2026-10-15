/// An optimized string pool compiler.
/// Accumulates, deduplicates, and packs arbitrary localization tokens using a compact 24:8 bit configuration.
package struct StringPoolBuilder {
    /// Maps unique strings to their pre-compiled, packed UInt32 layout coordinates (Offset + Length).
    private var deduplicationMap: [String: UInt32] = [:]

    /// Monolithic sequence accumulating raw contiguous UTF-8 characters across all compiled locales.
    private var rawBytes: [UInt8] = []

    package init() {}
}

package extension StringPoolBuilder {
    /// Returns the absolute number of compiled bytes currently held within the String Pool data segment.
    var count: Int {
        rawBytes.count
    }

    /// Registers an input string into the pool. If the token already exists, it is instantly
    /// deduplicated, returning its existing packed layout metadata (24 bits Offset : 8 bits Length).
    /// - Parameter string: The raw format pattern string or calendar entity token from CLDR.
    /// - Returns: A packed UInt32 integer carrying physical address offsets and byte counts.
    mutating func insert(_ string: String) -> UInt32 {
        if let packedValue = deduplicationMap[string] {
            return packedValue
        }

        let currentOffset = UInt32(rawBytes.count)
        let utf8Bytes = Array(string.utf8)
        let length = UInt32(utf8Bytes.count)

        precondition(
            length <= 255,
            "String length (\(length) bytes) for token '\(string)' exceeds the 8-bit allocation limit of 255."
        )
        precondition(
            currentOffset <= 0xFFFFFF,
            "The total String Pool size has breached the maximum 24-bit addressing threshold (16.7 MB)."
        )

        rawBytes.append(contentsOf: utf8Bytes)

        let packedValue = (currentOffset << 8) | (length & 0xFF)
        deduplicationMap[string] = packedValue

        return packedValue
    }

    /// Registers a complete sequence of 12 month string identifiers into the pool, converting them into a fixed binary representation.
    ///
    /// Every string parameter passed into this utility is individually checked for duplicates within the central pool cache,
    /// packed down using a 24:8 compression scheme, and placed contiguously inside an inline stack-allocated memory structure.
    ///
    /// - Parameter months: A flat array containing exactly 12 localized text entries (e.g., January through December).
    /// - Returns: A 12-element fixed tuple containing packed `UInt32` pointer coordinates (Offset + Length) mapping sequentially to the string pool.
    /// - Precondition: The input `months` collection must contain exactly 12 raw text items.
    mutating func insert12(months: [String]) -> (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    ) {
        precondition(months.count == 12, "CLDR Mismatch: Expected exactly 12 elements for months database.")
        return (
            insert(months[0]), insert(months[1]), insert(months[2]), insert(months[3]),
            insert(months[4]), insert(months[5]), insert(months[6]), insert(months[7]),
            insert(months[8]), insert(months[9]), insert(months[10]), insert(months[11])
        )
    }

    /// Registers a complete sequence of 7 day string identifiers into the pool, converting them into a fixed binary representation.
    ///
    /// Every string parameter passed into this utility is individually checked for duplicates within the central pool cache,
    /// packed down using a 24:8 compression scheme, and placed contiguously inside an inline stack-allocated memory structure.
    ///
    /// - Parameter days: A flat array containing exactly 7 localized text entries starting from Sunday (index 0) to Saturday (index 6).
    /// - Returns: A 7-element fixed tuple containing packed `UInt32` pointer coordinates (Offset + Length) mapping sequentially to the string pool.
    /// - Precondition: The input `days` collection must contain exactly 7 raw text items.
    mutating func insert7(days: [String]) -> (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) {
        precondition(days.count == 7, "CLDR Mismatch: Expected exactly 7 elements for days database.")
        return (
            insert(days[0]), insert(days[1]), insert(days[2]), insert(days[3]),
            insert(days[4]), insert(days[5]), insert(days[6])
        )
    }

    /// Registers a complete sequence of 4 quarter string identifiers into the pool, converting them into a fixed binary representation.
    ///
    /// - Parameter quarters: A flat array containing exactly 4 localized text entries mapped sequentially from Q1 to Q4.
    /// - Returns: A 4-element fixed tuple containing packed UInt32 pointer coordinates (Offset + Length).
    /// - Precondition: The input collection must contain exactly 4 raw text items.
    mutating func insert4(quarters: [String]) -> (UInt32, UInt32, UInt32, UInt32) {
        precondition(quarters.count == 4, "CLDR Mismatch: Expected exactly 4 elements for quarters database.")
        return (insert(quarters[0]), insert(quarters[1]), insert(quarters[2]), insert(quarters[3]))
    }

    /// Registers a complete sequence of 2 day period identifiers (AM/PM) into the pool.
    /// - Parameter periods: An array containing exactly 2 elements: index 0 for AM, index 1 for PM.
    /// - Returns: A packed 2-element UInt32 tuple.
    mutating func insert2(periods: [String]) -> (UInt32, UInt32) {
        precondition(periods.count == 2, "CLDR Mismatch: Expected exactly 2 elements for AM/PM periods.")
        return (insert(periods[0]), insert(periods[1]))
    }

    /// Forces section memory alignment by padding trailing data blocks to a standard 4-byte hardware boundary.
    /// Must be invoked at the conclusion of Pass 1 prior to merging with the global binary tree.
    mutating func build() -> [UInt8] {
        while rawBytes.count % 4 != 0 {
            rawBytes.append(0)
        }

        return rawBytes
    }
}
