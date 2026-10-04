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
