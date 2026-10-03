@testable import ChronoCalendar
import Testing

struct NanosecondMathTests {
    @Test("NanosecondMathTests: Span for digits mapping", arguments: [
        (0, 1_000_000_000), // 0 digits = 1 second
        (3, 1_000_000), // 3 digits = 1 millisecond
        (6, 1000), // 6 digits = 1 microsecond
        (9, 1), // 9 digits = 1 nanosecond
        (12, 1), // Cap at 1
    ])
    func spanMapping(digits: Int, expected: Int64) {
        #expect(NanosecondMath.span(forDigits: digits) == expected)
    }

    @Test("NanosecondMathTests: Time padding format", arguments: [
        (0, "00"),
        (9, "09"),
        (10, "10"),
        (59, "59")
    ])
    func padding(value: Int, expected: String) {
        #expect(value.paddedTwoDigit == expected)
    }
}
