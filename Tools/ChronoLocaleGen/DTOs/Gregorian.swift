import Foundation

struct Gregorian: Decodable {
    let main: [String: GregorianLocaleContainer]
}

struct GregorianLocaleContainer: Decodable {
    let dates: GregorianDatesContainer
}

struct GregorianDatesContainer: Decodable {
    let calendars: GregorianCalendarsContainer
}

struct GregorianCalendarsContainer: Decodable {
    let gregorian: GregorianCalendarData
}

struct GregorianCalendarData: Decodable {
    let months: CalendarContextContainer<MonthWidthContainer>
    let days: CalendarContextContainer<DayWidthContainer>

    let quarters: CalendarContextContainer<QuarterWidthContainer>
    let dayPeriods: CalendarContextContainer<DayWidthContainer>
    let eras: EraContainer

    let dateFormats: FormatStyleContainer
    let timeFormats: FormatStyleContainer
    let dateTimeFormats: FormatStyleContainer

    let dateSkeletons: FormatStyleContainer?
    let timeSkeletons: FormatStyleContainer?
}

extension GregorianCalendarData {
    /// Extracts month names in strict chronological order from January ("1") to December ("12").
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container (e.g., wide, abbreviated, narrow) inside the formatting context.
    /// - Returns: A sequentially ordered array containing exactly 12 month string values.
    func orderedFormatMonths(for widthKeyPath: KeyPath<MonthWidthContainer, [String: String]>) -> [String] {
        let container = months.format
        let widthMap = container[keyPath: widthKeyPath]
        return (1 ... 12).map { widthMap[String($0)] ?? "" }
    }

    /// Extracts standalone month names in strict chronological order from January ("1") to December ("12").
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container (e.g., wide, abbreviated, narrow) inside the standalone context.
    /// - Returns: A sequentially ordered array containing exactly 12 standalone month string values.
    func orderedStandaloneMonths(for widthKeyPath: KeyPath<MonthWidthContainer, [String: String]>) -> [String] {
        let container = months.standAlone
        let widthMap = container[keyPath: widthKeyPath]
        return (1 ... 12).map { widthMap[String($0)] ?? "" }
    }

    /// Extracts day names in strict chronological order starting from Sunday ("sun") to Saturday ("sat").
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container (e.g., wide, abbreviated, narrow) inside the formatting context.
    /// - Returns: A sequentially ordered array containing exactly 7 day string values.
    func orderedFormatDays(for widthKeyPath: KeyPath<DayWidthContainer, [String: String]>) -> [String] {
        let container = days.format
        let widthMap = container[keyPath: widthKeyPath]
        let daysKeys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
        return daysKeys.map { widthMap[$0] ?? "" }
    }

    /// Extracts optional day name configurations (such as short forms), providing robust structural fallback paths if missing.
    ///
    /// This method resolves the target width from the formatting container first. If missing, it checks the standalone
    /// container. If completely absent from both, it defaults gracefully to the standard abbreviated day format to protect data integrity.
    ///
    /// - Parameter widthKeyPath: The keypath targeting an optional display width container dictionary block.
    /// - Returns: A sequentially ordered array containing exactly 7 day string values mapped from Sunday to Saturday.
    func orderedOptionalDays(for widthKeyPath: KeyPath<DayWidthContainer, [String: String]?>) -> [String] {
        let formatContainer = days.format
        let standaloneContainer = days.standAlone

        let widthMap = formatContainer[keyPath: widthKeyPath] ?? standaloneContainer[keyPath: widthKeyPath] ?? formatContainer.abbreviated
        let daysKeys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
        return daysKeys.map { widthMap[$0] ?? formatContainer.abbreviated[$0] ?? "" }
    }

    /// Extracts standalone day names in strict chronological order starting from Sunday ("sun") to Saturday ("sat").
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container (e.g., wide, abbreviated, narrow) inside the standalone context.
    /// - Returns: A sequentially ordered array containing exactly 7 standalone day string values.
    func orderedStandaloneDays(for widthKeyPath: KeyPath<DayWidthContainer, [String: String]>) -> [String] {
        let container = days.standAlone
        let widthMap = container[keyPath: widthKeyPath]
        let daysKeys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
        return daysKeys.map { widthMap[$0] ?? "" }
    }

    /// Extracts quarter names in strict chronological order from Q1 ("1") to Q4 ("4") within a formatting context.
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container inside the formatting context.
    /// - Returns: A sequentially ordered array containing exactly 4 quarter string values.
    func orderedFormatQuarters(for widthKeyPath: KeyPath<QuarterWidthContainer, [String: String]>) -> [String] {
        let container = quarters.format
        let widthMap = container[keyPath: widthKeyPath]
        return (1 ... 4).map { widthMap[String($0)] ?? "" }
    }

    /// Extracts standalone quarter names in strict chronological order from Q1 ("1") to Q4 ("4") within a standalone label context.
    ///
    /// - Parameter widthKeyPath: The keypath targeting a specific display width container inside the standalone context.
    /// - Returns: A sequentially ordered array containing exactly 4 standalone quarter string values.
    func orderedStandaloneQuarters(for widthKeyPath: KeyPath<QuarterWidthContainer, [String: String]>) -> [String] {
        let container = quarters.standAlone
        let widthMap = container[keyPath: widthKeyPath]
        return (1 ... 4).map { widthMap[String($0)] ?? "" }
    }

    /// Extracts localized AM and PM text nodes in strict chronological order within a specific formatting context.
    ///
    /// This utility maps regional day period markers into a predictable sequence: index `0` resolves to the AM
    /// value, and index `1` resolves to the PM value.
    ///
    /// - Parameters:
    ///   - contextKeyPath: The structural path targeting the source calendar day period container block.
    ///   - widthKeyPath: The layout path specifying the dynamic width variant (e.g., wide, abbreviated, narrow) to pull from.
    /// - Returns: A sequentially ordered array containing exactly 2 day-period string representations: `[AM, PM]`.
    func orderedFormatDayPeriods(
        for contextKeyPath: KeyPath<GregorianCalendarData, CalendarContextContainer<DayWidthContainer>>,
        widthKeyPath: KeyPath<DayWidthContainer, [String: String]>
    ) -> [String] {
        let container = self[keyPath: contextKeyPath]
        let widthMap = container.format[keyPath: widthKeyPath]
        return [widthMap["am"] ?? "", widthMap["pm"] ?? ""]
    }

    /// Extracts localized standalone AM and PM text nodes in strict chronological order within a standalone label context.
    ///
    /// This utility maps regional standalone day period markers into a predictable sequence: index `0` resolves to
    /// the AM value, and index `1` resolves to the PM value.
    ///
    /// - Parameters:
    ///   - contextKeyPath: The structural path targeting the source calendar day period container block.
    ///   - widthKeyPath: The layout path specifying the dynamic width variant (e.g., wide, abbreviated, narrow) to pull from.
    /// - Returns: A sequentially ordered array containing exactly 2 standalone day-period string representations: `[AM, PM]`.
    func orderedStandaloneDayPeriods(
        for contextKeyPath: KeyPath<GregorianCalendarData, CalendarContextContainer<DayWidthContainer>>,
        widthKeyPath: KeyPath<DayWidthContainer, [String: String]>
    ) -> [String] {
        let container = self[keyPath: contextKeyPath]
        let widthMap = container.standAlone[keyPath: widthKeyPath]
        return [widthMap["am"] ?? "", widthMap["pm"] ?? ""]
    }
}

struct CalendarContextContainer<Context: Decodable>: Decodable {
    let format: Context
    let standAlone: Context

    enum CodingKeys: String, CodingKey {
        case format
        case standAlone = "stand-alone"
    }
}

struct MonthWidthContainer: Decodable {
    let abbreviated: [String: String]
    let narrow: [String: String]
    let wide: [String: String]
}

struct DayWidthContainer: Decodable {
    let abbreviated: [String: String]
    let narrow: [String: String]
    let short: [String: String]?
    let wide: [String: String]
}

struct QuarterWidthContainer: Decodable {
    let abbreviated: [String: String]
    let narrow: [String: String]
    let wide: [String: String]
}

struct DayPeriodWidthContainer: Decodable {
    let abbreviated: [String: String]
    let narrow: [String: String]
    let wide: [String: String]
}

struct EraContainer: Decodable {
    let eraNames: [String: String]
    let eraAbbr: [String: String]
    let eraNarrow: [String: String]
}

struct FormatStyleContainer {
    let full: String
    let long: String
    let medium: String
    let short: String
}

extension FormatStyleContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case full, long, medium, short
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        full = try container.decodeFlexibleString(forKey: .full)
        long = try container.decodeFlexibleString(forKey: .long)
        medium = try container.decodeFlexibleString(forKey: .medium)
        short = try container.decodeFlexibleString(forKey: .short)
    }
}

extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) throws -> String {
        if let directString = try? decode(String.self, forKey: key) {
            return directString
        }

        if let wrappedString = try? decode(ValueWrapper.self, forKey: key) {
            return wrappedString.value
        }

        throw DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: codingPath + [key],
                debugDescription: "Failed to extract a valid format pattern string from the CLDR data structure."
            )
        )
    }
}

struct ValueWrapper: Decodable {
    let value: String
    let numbers: String?

    enum CodingKeys: String, CodingKey {
        case value = "_value"
        case numbers = "_numbers"
    }
}
