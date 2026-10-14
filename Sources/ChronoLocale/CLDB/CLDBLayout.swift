import ChronoSystem

package struct CLDBLayout {
    package let header: LocaleHeaderLayout
    package let indexes: [LocaleIndexNodeLayout]
    package let blocks: [LocaleBlockLayout]
    package let stringPool: [UInt8]

    package init(
        header: LocaleHeaderLayout,
        indexes: [LocaleIndexNodeLayout],
        blocks: [LocaleBlockLayout],
        stringPool: [UInt8]
    ) {
        self.header = header
        self.indexes = indexes
        self.blocks = blocks
        self.stringPool = stringPool
    }
}

package struct LocaleHeaderLayout {
    package let magic: FixedMagic
    package let version: UInt32
    package let localeCount: UInt32
    package let stringPoolOffset: UInt32

    package init(
        magic: FixedMagic,
        version: UInt32,
        localeCount: UInt32,
        stringPoolOffset: UInt32
    ) {
        self.magic = magic
        self.version = version
        self.localeCount = localeCount
        self.stringPoolOffset = stringPoolOffset
    }
}

package struct LocaleIndexNodeLayout {
    package let localeHash: UInt32
    package let blockOffset: UInt32

    package init(
        localeHash: UInt32,
        blockOffset: UInt32
    ) {
        self.localeHash = localeHash
        self.blockOffset = blockOffset
    }
}

package struct LocaleBlockLayout {
    // A. Date/Time Format Styles (12 * 4 = 48 bytes)
    package let dateFormatFull: UInt32
    package let dateFormatLong: UInt32
    package let dateFormatMedium: UInt32
    package let dateFormatShort: UInt32

    package let timeFormatFull: UInt32
    package let timeFormatLong: UInt32
    package let timeFormatMedium: UInt32
    package let timeFormatShort: UInt32

    package let dateTimeFormatFull: UInt32
    package let dateTimeFormatLong: UInt32
    package let dateTimeFormatMedium: UInt32
    package let dateTimeFormatShort: UInt32

    /// B. Months (12 elements * 6 variants * 4 bytes = 288 bytes)
    package let monthsFormatWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsFormatAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsFormatNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    package let monthsStandaloneWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsStandaloneAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsStandaloneNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    // C. Days (7 elements * 8 variants * 4 bytes = 224 bytes)
    // Starting from Sunday (index 0) to Saturday (index 6)
    package let daysFormatWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    package let daysStandaloneWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    // D. Eras (2 elements * 3 variants * 4 bytes = 24 bytes)
    // (BCE, CE)
    package let erasWide: (UInt32, UInt32)
    package let erasAbbreviated: (UInt32, UInt32)
    package let erasNarrow: (UInt32, UInt32)

    package init(
        dateFormatFull: UInt32,
        dateFormatLong: UInt32,
        dateFormatMedium: UInt32,
        dateFormatShort: UInt32,
        timeFormatFull: UInt32,
        timeFormatLong: UInt32,
        timeFormatMedium: UInt32,
        timeFormatShort: UInt32,
        dateTimeFormatFull: UInt32,
        dateTimeFormatLong: UInt32,
        dateTimeFormatMedium: UInt32,
        dateTimeFormatShort: UInt32,
        monthsFormatWide: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsFormatAbbreviated: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsFormatNarrow: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneWide: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneAbbreviated: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneNarrow: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        daysFormatWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        erasWide: (UInt32, UInt32),
        erasAbbreviated: (UInt32, UInt32),
        erasNarrow: (UInt32, UInt32)
    ) {
        self.dateFormatFull = dateFormatFull
        self.dateFormatLong = dateFormatLong
        self.dateFormatMedium = dateFormatMedium
        self.dateFormatShort = dateFormatShort

        self.timeFormatFull = timeFormatFull
        self.timeFormatLong = timeFormatLong
        self.timeFormatMedium = timeFormatMedium
        self.timeFormatShort = timeFormatShort

        self.dateTimeFormatFull = dateTimeFormatFull
        self.dateTimeFormatLong = dateTimeFormatLong
        self.dateTimeFormatMedium = dateTimeFormatMedium
        self.dateTimeFormatShort = dateTimeFormatShort

        self.monthsFormatWide = monthsFormatWide
        self.monthsFormatAbbreviated = monthsFormatAbbreviated
        self.monthsFormatNarrow = monthsFormatNarrow

        self.monthsStandaloneWide = monthsStandaloneWide
        self.monthsStandaloneAbbreviated = monthsStandaloneAbbreviated
        self.monthsStandaloneNarrow = monthsStandaloneNarrow

        self.daysFormatWide = daysFormatWide
        self.daysFormatAbbreviated = daysFormatAbbreviated
        self.daysFormatNarrow = daysFormatNarrow
        self.daysFormatShort = daysFormatShort

        self.daysStandaloneWide = daysStandaloneWide
        self.daysStandaloneAbbreviated = daysStandaloneAbbreviated
        self.daysStandaloneNarrow = daysStandaloneNarrow
        self.daysStandaloneShort = daysStandaloneShort

        self.erasWide = erasWide
        self.erasAbbreviated = erasAbbreviated
        self.erasNarrow = erasNarrow
    }
}

/// An optimized string pool compiler.
/// Accumulates, deduplicates, and packs arbitrary localization tokens using a compact 24:8 bit configuration.
package struct StringPoolBuilder {
    /// Maps unique strings to their pre-compiled, packed UInt32 layout coordinates (Offset + Length).
    private var deduplicationMap: [String: UInt32] = [:]

    /// Monolithic sequence accumulating raw contiguous UTF-8 characters across all compiled locales.
    private var rawBytes: [UInt8] = []

    package init() {}

    /// Returns the absolute number of compiled bytes currently held within the String Pool data segment.
    package var count: Int {
        rawBytes.count
    }

    /// Registers an input string into the pool. If the token already exists, it is instantly
    /// deduplicated, returning its existing packed layout metadata (24 bits Offset : 8 bits Length).
    /// - Parameter string: The raw format pattern string or calendar entity token from CLDR.
    /// - Returns: A packed UInt32 integer carrying physical address offsets and byte counts.
    package mutating func insert(_ string: String) -> UInt32 {
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
    package mutating func insert12(months: [String]) -> (
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
    package mutating func insert7(days: [String]) -> (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32) {
        precondition(days.count == 7, "CLDR Mismatch: Expected exactly 7 elements for days database.")
        return (
            insert(days[0]), insert(days[1]), insert(days[2]), insert(days[3]),
            insert(days[4]), insert(days[5]), insert(days[6])
        )
    }

    /// Forces section memory alignment by padding trailing data blocks to a standard 4-byte hardware boundary.
    /// Must be invoked at the conclusion of Pass 1 prior to merging with the global binary tree.
    package mutating func build() -> [UInt8] {
        while rawBytes.count % 4 != 0 {
            rawBytes.append(0)
        }

        return rawBytes
    }
}
