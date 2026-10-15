@testable import ChronoLocale
@testable import ChronoLocaleGen
import Foundation
import Testing

struct CLDBCompilerTests {
    // swiftlint:disable function_parameter_count
    /// Generates a minimal compliant valid mock data structure of GregorianCalendarData for isolated pipeline validation.
    private func makeMockCalendarData(
        monthWide: String,
        dayWide: String,
        quarterWide: String,
        amMarker: String,
        pmMarker: String,
        skeletonPattern: String
    ) -> GregorianCalendarData {
        let monthContainer = MonthWidthContainer(
            abbreviated: ["1": "Jan"],
            narrow: ["1": "J"],
            wide: ["1": monthWide]
        )

        let dayContainer = DayWidthContainer(
            abbreviated: ["sun": "Sun"],
            narrow: ["sun": "S"],
            short: ["sun": "Su"],
            wide: ["sun": dayWide]
        )

        let quarterContainer = QuarterWidthContainer(
            abbreviated: ["1": "Q1"],
            narrow: ["1": "1"],
            wide: ["1": quarterWide]
        )

        let formatStyle = FormatStyleContainer(
            full: "yyyy-MM-dd",
            long: "yyyy-MM-dd",
            medium: "yyyy-MM-dd",
            short: "yyyy-MM-dd"
        )

        let amPmMap = ["am": amMarker, "pm": pmMarker]
        let amPmContainer = DayWidthContainer(
            abbreviated: amPmMap,
            narrow: amPmMap,
            short: amPmMap,
            wide: amPmMap
        )

        let skeletonStyle = FormatStyleContainer(
            full: skeletonPattern,
            long: skeletonPattern,
            medium: skeletonPattern,
            short: skeletonPattern
        )

        return GregorianCalendarData(
            months: CalendarContextContainer(format: monthContainer, standAlone: monthContainer),
            days: CalendarContextContainer(format: dayContainer, standAlone: dayContainer),
            quarters: CalendarContextContainer(format: quarterContainer, standAlone: quarterContainer),
            dayPeriods: CalendarContextContainer(format: amPmContainer, standAlone: amPmContainer),
            eras: EraContainer(eraNames: ["0": "BCE", "1": "CE"], eraAbbr: ["0": "BCE", "1": "CE"], eraNarrow: ["0": "BCE", "1": "CE"]),
            dateFormats: formatStyle,
            timeFormats: formatStyle,
            dateTimeFormats: formatStyle,
            dateSkeletons: skeletonStyle,
            timeSkeletons: skeletonStyle
        )
    }

    // swiftlint:enable function_parameter_count

    @Test("CLDBCompilerTests: Verify Two-Pass Compilation orchestrates structural sorting and boundary constraints")
    func twoPassCompilationFlow() {
        // Setup raw input models simulating distinct languages (e.g., English and Indonesian)
        let decodedLocales: [String: GregorianCalendarData] = [
            "id_ID": makeMockCalendarData(
                monthWide: "Januari",
                dayWide: "Minggu",
                quarterWide: "Kuartal 1",
                amMarker: "AM",
                pmMarker: "PM",
                skeletonPattern: "yMd"
            ),
            "en_US": makeMockCalendarData(
                monthWide: "January",
                dayWide: "Sunday",
                quarterWide: "1st Quarter",
                amMarker: "AM",
                pmMarker: "PM",
                skeletonPattern: "yMd"
            ),
        ]

        // Trigger the target execution pipeline compiler block
        let compiledLayout = CLDBCompiler.compile(from: decodedLocales, schemaVersion: 3)

        // Verify Segment 1: Header Blueprint Layout Mapping
        #expect(compiledLayout.header.magic == .cldb, "Header magic signature must register as the '.cldb' identifier.")
        #expect(compiledLayout.header.version == 3, "Schema version tracking data drift detected inside the root header layout.")
        #expect(compiledLayout.header.localeCount == 2, "Compiler tracking registry mismatch: total locales parsed must equal 2.")

        // Verify Segment 2: Strict Numeric Index Array Sorting
        #expect(compiledLayout.indexes.count == 2, "Index row table nodes count error.")
        let firstNode = compiledLayout.indexes[0]
        let secondNode = compiledLayout.indexes[1]

        // Enforce the requirement that the second-pass sorts all nodes ascending based on FNV-1a integer keys
        #expect(firstNode.localeHash < secondNode.localeHash, "Pipeline compilation failed: Index nodes layout must be sorted numerically ascending.")

        // Verify Segment 3: Memory Address Block Offsets Jumps Arithmetic
        let headerSize = UInt32(MemoryLayout<LocaleHeaderLayout>.size) // 16 bytes
        let indexTableSize = UInt32(compiledLayout.indexes.count * MemoryLayout<LocaleIndexNodeLayout>.size) // 2 * 8 = 16 bytes
        let blockSize = UInt32(MemoryLayout<LocaleBlockLayout>.size) // 760 bytes

        let expectedFirstBlockOffset = headerSize + indexTableSize
        let expectedSecondBlockOffset = expectedFirstBlockOffset + blockSize
        let expectedStringPoolOffset = expectedSecondBlockOffset + blockSize

        #expect(firstNode.blockOffset == expectedFirstBlockOffset, "First compiled layout block offset calculated incorrectly.")
        #expect(secondNode.blockOffset == expectedSecondBlockOffset, "Second compiled layout block offset calculation error.")
        #expect(
            compiledLayout.header.stringPoolOffset == expectedStringPoolOffset,
            "The global string pool starting pointer coordinate drifted from structural bounds."
        )

        // Verify Segment 4: Global String Pool Trailing Data Blocks Buffer
        #expect(!compiledLayout.stringPool.isEmpty, "String pool buffer compilation empty.")
        #expect(compiledLayout.stringPool.count % 4 == 0, "Hardware optimization restriction failed: String pool byte footprint must be a multiple of 4.")
    }
}
