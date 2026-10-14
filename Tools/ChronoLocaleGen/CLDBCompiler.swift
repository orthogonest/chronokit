import ChronoLocale
import ChronoSystem

/// A two-pass compiler designed to transform raw decoded CLDR representations into packed binary layouts.
enum CLDBCompiler {
    /// Internal execution context bridging data states between the first and second compilation passes.
    private struct Context {
        let blockMetadatas: [BlockMetadata]
        let stringPoolBytes: [UInt8]
    }

    /// Transient metadata tracking mapped language layouts alongside their deterministic sorting metrics.
    private struct BlockMetadata {
        let localeIdentifier: String
        let hash: UInt32
        let block: LocaleBlockLayout
    }

    /// Compiles parsed raw CLDR DTO data representations into a finalized packed binary CLDBLayout payload.
    ///
    /// - Parameters:
    ///   - decodedLocales: A collection of fully parsed Gregorian DTO structures mapped by their locale identifier strings.
    ///   - schemaVersion: The protocol design version increment descriptor tag to write into the header.
    /// - Returns: A tightly bound, hardware-aligned CLDBLayout containing serialized index nodes and string offsets.
    static func compile(
        from decodedLocales: [String: GregorianCalendarData],
        schemaVersion: UInt32 = 1
    ) -> CLDBLayout {
        return secondPass(from: firstPass(from: decodedLocales), schemaVersion: schemaVersion)
    }

    // swiftlint:disable function_body_length line_length
    /// Executes the first pass of the compilation pipeline by gathering raw CLDR strings,
    /// deduplicating them, and building un-aligned structural locale blocks.
    ///
    /// This function transforms localized names (months, days, eras) and pattern format styles
    /// from all input languages into unique `UInt32` layout descriptors (Offset + Length)
    /// via a bit-packed string pool map. At the end of this pass, the accumulated language
    /// metadata collection is sorted by its FNV-1a hash ascending.
    ///
    /// - Parameter decodedLocales: A map of parsed DTO model elements keyed by their locale string ID.
    /// - Returns: A transient compilation `Context` containing pre-sorted locale structures and padded string pool bytes.
    private static func firstPass(from decodedLocales: [String: GregorianCalendarData]) -> Context {
        var stringPoolBuilder = StringPoolBuilder()

        var blockMetadatas: [BlockMetadata] = []
        blockMetadatas.reserveCapacity(decodedLocales.count)

        for (localeIdentifier, data) in decodedLocales {
            let hash = FNV1a.hash32(localeIdentifier)

            // Pack Format Styles Segment
            let dateFormatFull = stringPoolBuilder.insert(data.dateFormats.full)
            let dateFormatLong = stringPoolBuilder.insert(data.dateFormats.long)
            let dateFormatMedium = stringPoolBuilder.insert(data.dateFormats.medium)
            let dateFormatShort = stringPoolBuilder.insert(data.dateFormats.short)

            let timeFormatFull = stringPoolBuilder.insert(data.timeFormats.full)
            let timeFormatLong = stringPoolBuilder.insert(data.timeFormats.long)
            let timeFormatMedium = stringPoolBuilder.insert(data.timeFormats.medium)
            let timeFormatShort = stringPoolBuilder.insert(data.timeFormats.short)

            let dateTimeFormatFull = stringPoolBuilder.insert(data.dateTimeFormats.full)
            let dateTimeFormatLong = stringPoolBuilder.insert(data.dateTimeFormats.long)
            let dateTimeFormatMedium = stringPoolBuilder.insert(data.dateTimeFormats.medium)
            let dateTimeFormatShort = stringPoolBuilder.insert(data.dateTimeFormats.short)

            // Pack Months Array Variants into Tuples
            let monthsFormatWide = stringPoolBuilder.insert12(months: data.orderedFormatMonths(for: \.wide))
            let monthsFormatAbbreviated = stringPoolBuilder.insert12(months: data.orderedFormatMonths(for: \.abbreviated))
            let monthsFormatNarrow = stringPoolBuilder.insert12(months: data.orderedFormatMonths(for: \.narrow))

            let monthsStandaloneWide = stringPoolBuilder.insert12(months: data.orderedStandaloneMonths(for: \.wide))
            let monthsStandaloneAbbreviated = stringPoolBuilder.insert12(months: data.orderedStandaloneMonths(for: \.abbreviated))
            let monthsStandaloneNarrow = stringPoolBuilder.insert12(months: data.orderedStandaloneMonths(for: \.narrow))

            // Pack Days Array Variants into Tuples
            let daysFormatWide = stringPoolBuilder.insert7(days: data.orderedFormatDays(for: \.wide))
            let daysFormatAbbreviated = stringPoolBuilder.insert7(days: data.orderedFormatDays(for: \.abbreviated))
            let daysFormatNarrow = stringPoolBuilder.insert7(days: data.orderedFormatDays(for: \.narrow))
            let daysFormatShort = stringPoolBuilder.insert7(days: data.orderedOptionalDays(for: \.short))

            let daysStandaloneWide = stringPoolBuilder.insert7(days: data.orderedStandaloneDays(for: \.wide))
            let daysStandaloneAbbreviated = stringPoolBuilder.insert7(days: data.orderedStandaloneDays(for: \.abbreviated))
            let daysStandaloneNarrow = stringPoolBuilder.insert7(days: data.orderedStandaloneDays(for: \.narrow))
            let daysStandaloneShort = stringPoolBuilder.insert7(days: data.orderedOptionalDays(for: \.short))

            // Pack Quarters Segment (4 Elements Variants into Tuples)
            let quartersFormatWide = stringPoolBuilder.insert4(quarters: data.orderedFormatQuarters(for: \.wide))
            let quartersFormatAbbreviated = stringPoolBuilder.insert4(quarters: data.orderedFormatQuarters(for: \.abbreviated))
            let quartersFormatNarrow = stringPoolBuilder.insert4(quarters: data.orderedFormatQuarters(for: \.narrow))

            let quartersStandaloneWide = stringPoolBuilder.insert4(quarters: data.orderedStandaloneQuarters(for: \.wide))
            let quartersStandaloneAbbreviated = stringPoolBuilder.insert4(quarters: data.orderedStandaloneQuarters(for: \.abbreviated))
            let quartersStandaloneNarrow = stringPoolBuilder.insert4(quarters: data.orderedStandaloneQuarters(for: \.narrow))

            // Pack Day Periods Segment (AM/PM Variants into Tuples)
            let dayPeriodsFormatWide = stringPoolBuilder.insert2(periods: data.orderedFormatDayPeriods(for: \.dayPeriods, widthKeyPath: \.wide))
            let dayPeriodsFormatAbbreviated = stringPoolBuilder.insert2(periods: data.orderedFormatDayPeriods(for: \.dayPeriods, widthKeyPath: \.abbreviated))
            let dayPeriodsFormatNarrow = stringPoolBuilder.insert2(periods: data.orderedFormatDayPeriods(for: \.dayPeriods, widthKeyPath: \.narrow))

            let dayPeriodsStandaloneWide = stringPoolBuilder.insert2(periods: data.orderedStandaloneDayPeriods(for: \.dayPeriods, widthKeyPath: \.wide))
            let dayPeriodsStandaloneAbbreviated = stringPoolBuilder.insert2(periods: data.orderedStandaloneDayPeriods(for: \.dayPeriods, widthKeyPath: \.abbreviated))
            let dayPeriodsStandaloneNarrow = stringPoolBuilder.insert2(periods: data.orderedStandaloneDayPeriods(for: \.dayPeriods, widthKeyPath: \.narrow))

            // Pack Eras Segment (Keys "0" for BCE and "1" for CE)
            let erasWide = (
                stringPoolBuilder.insert(data.eras.eraNames["0"] ?? ""),
                stringPoolBuilder.insert(data.eras.eraNames["1"] ?? "")
            )
            let erasAbbreviated = (
                stringPoolBuilder.insert(data.eras.eraAbbr["0"] ?? ""),
                stringPoolBuilder.insert(data.eras.eraAbbr["1"] ?? "")
            )
            let erasNarrow = (
                stringPoolBuilder.insert(data.eras.eraNarrow["0"] ?? ""),
                stringPoolBuilder.insert(data.eras.eraNarrow["1"] ?? "")
            )

            // Pack Skeletons Segment (Fallback to empty string if missing in CLDR JSON)
            let dateSkeletonFull = stringPoolBuilder.insert(data.dateSkeletons?.full ?? "")
            let dateSkeletonLong = stringPoolBuilder.insert(data.dateSkeletons?.long ?? "")
            let dateSkeletonMedium = stringPoolBuilder.insert(data.dateSkeletons?.medium ?? "")
            let dateSkeletonShort = stringPoolBuilder.insert(data.dateSkeletons?.short ?? "")

            let timeSkeletonFull = stringPoolBuilder.insert(data.timeSkeletons?.full ?? "")
            let timeSkeletonLong = stringPoolBuilder.insert(data.timeSkeletons?.long ?? "")
            let timeSkeletonMedium = stringPoolBuilder.insert(data.timeSkeletons?.medium ?? "")
            let timeSkeletonShort = stringPoolBuilder.insert(data.timeSkeletons?.short ?? "")

            let blockLayout = LocaleBlockLayout(
                dateFormatFull: dateFormatFull,
                dateFormatLong: dateFormatLong,
                dateFormatMedium: dateFormatMedium,
                dateFormatShort: dateFormatShort,
                timeFormatFull: timeFormatFull,
                timeFormatLong: timeFormatLong,
                timeFormatMedium: timeFormatMedium,
                timeFormatShort: timeFormatShort,
                dateTimeFormatFull: dateTimeFormatFull,
                dateTimeFormatLong: dateTimeFormatLong,
                dateTimeFormatMedium: dateTimeFormatMedium,
                dateTimeFormatShort: dateTimeFormatShort,
                monthsFormatWide: monthsFormatWide,
                monthsFormatAbbreviated: monthsFormatAbbreviated,
                monthsFormatNarrow: monthsFormatNarrow,
                monthsStandaloneWide: monthsStandaloneWide,
                monthsStandaloneAbbreviated: monthsStandaloneAbbreviated,
                monthsStandaloneNarrow: monthsStandaloneNarrow,
                daysFormatWide: daysFormatWide,
                daysFormatAbbreviated: daysFormatAbbreviated,
                daysFormatNarrow: daysFormatNarrow,
                daysFormatShort: daysFormatShort,
                daysStandaloneWide: daysStandaloneWide,
                daysStandaloneAbbreviated: daysStandaloneAbbreviated,
                daysStandaloneNarrow: daysStandaloneNarrow,
                daysStandaloneShort: daysStandaloneShort,
                quartersFormatWide: quartersFormatWide,
                quartersFormatAbbreviated: quartersFormatAbbreviated,
                quartersFormatNarrow: quartersFormatNarrow,
                quartersStandaloneWide: quartersStandaloneWide,
                quartersStandaloneAbbreviated: quartersStandaloneAbbreviated,
                quartersStandaloneNarrow: quartersStandaloneNarrow,
                dayPeriodsFormatWide: dayPeriodsFormatWide,
                dayPeriodsFormatAbbreviated: dayPeriodsFormatAbbreviated,
                dayPeriodsFormatNarrow: dayPeriodsFormatNarrow,
                dayPeriodsStandaloneWide: dayPeriodsStandaloneWide,
                dayPeriodsStandaloneAbbreviated: dayPeriodsStandaloneAbbreviated,
                dayPeriodsStandaloneNarrow: dayPeriodsStandaloneNarrow,
                erasWide: erasWide,
                erasAbbreviated: erasAbbreviated,
                erasNarrow: erasNarrow,
                dateSkeletonFull: dateSkeletonFull,
                dateSkeletonLong: dateSkeletonLong,
                dateSkeletonMedium: dateSkeletonMedium,
                dateSkeletonShort: dateSkeletonShort,
                timeSkeletonFull: timeSkeletonFull,
                timeSkeletonLong: timeSkeletonLong,
                timeSkeletonMedium: timeSkeletonMedium,
                timeSkeletonShort: timeSkeletonShort
            )

            let blockMetadata = BlockMetadata(
                localeIdentifier: localeIdentifier,
                hash: hash,
                block: blockLayout
            )
            blockMetadatas.append(blockMetadata)
        }

        // Sort structures by their numeric hash code to enable stable O(log N) runtime Binary Search
        blockMetadatas.sort { $0.hash < $1.hash }

        let stringPoolBytes = stringPoolBuilder.build()

        return Context(
            blockMetadatas: blockMetadatas,
            stringPoolBytes: stringPoolBytes
        )
    }

    // swiftlint:enable function_body_length line_length

    /// Executes the second pass of the compilation pipeline by calculating physical memory layout offsets
    /// and generating the root file headers.
    ///
    /// This pass maps the linear memory layout of the final binary asset block. It computes exactly
    /// where each fixed-width language block will sit right after the index table, performs strict
    /// compile-time collision checks against the FNV-1a integer keys, and pins the trailing string pool offset pointer.
    ///
    /// - Parameters:
    ///   - context: The sorted structural database state emitting out of the previous first pass execution.
    ///   - schemaVersion: The protocol specification tag to embed directly into the layout header.
    /// - Returns: A tightly packed `CLDBLayout` container holding unified static schemas ready for byte serialization.
    private static func secondPass(from context: Context, schemaVersion: UInt32) -> CLDBLayout {
        let localeCount = UInt32(context.blockMetadatas.count)
        let headerSize = UInt32(MemoryLayout<LocaleHeaderLayout>.size)
        let indexTableSize = localeCount * UInt32(MemoryLayout<LocaleIndexNodeLayout>.size)

        var currentBlockOffset = headerSize + indexTableSize
        let blockSize = UInt32(MemoryLayout<LocaleBlockLayout>.size)

        var indexNodes: [LocaleIndexNodeLayout] = []
        indexNodes.reserveCapacity(context.blockMetadatas.count)
        var blocks: [LocaleBlockLayout] = []
        blocks.reserveCapacity(context.blockMetadatas.count)

        for metadata in context.blockMetadatas {
            // Guard for theoretical hash collisions at compile time before generating asset blob
            guard !indexNodes.contains(where: { $0.localeHash == metadata.hash }) else {
                fatalError("Compilation aborted: Hash collision found on locale code token '\(metadata.localeIdentifier)'.")
            }

            let node = LocaleIndexNodeLayout(localeHash: metadata.hash, blockOffset: currentBlockOffset)
            indexNodes.append(node)
            blocks.append(metadata.block)

            currentBlockOffset += blockSize
        }

        let headerLayout = LocaleHeaderLayout(
            magic: .cldb,
            version: schemaVersion,
            localeCount: localeCount,
            stringPoolOffset: currentBlockOffset
        )

        return CLDBLayout(
            header: headerLayout,
            indexes: indexNodes,
            blocks: blocks,
            stringPool: context.stringPoolBytes
        )
    }
}
