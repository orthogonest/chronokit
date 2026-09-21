@testable import ChronoCore
import Testing

struct DurationTests {
    // MARK: - Initialization & Normalization Tests

    @Test("DurationTests: Basic initialization")
    func basicInit() {
        let duration = Duration(seconds: 10, nanoseconds: 500)
        #expect(duration.seconds == 10)
        #expect(duration.nanoseconds == 500)
    }

    @Test("DurationTests: Normalization of large positive nanoseconds", arguments: [
        (0, 1_000_000_000, 1, 0),
        (5, 1_500_000_000, 6, 500_000_000),
        (0, 2_999_999_999, 2, 999_999_999)
    ])
    func normalizationPositive(s: Int64, n: Int64, expS: Int64, expN: Int32) {
        let duration = Duration(seconds: s, nanoseconds: n)
        #expect(duration.seconds == expS)
        #expect(duration.nanoseconds == expN)
    }

    @Test("DurationTests: Normalization of negative nanoseconds", arguments: [
        (0, -1, -1, 999_999_999),
        (0, -1_000_000_000, -1, 0),
        (0, -1_500_000_000, -2, 500_000_000),
        (10, -1, 9, 999_999_999)
    ])
    func normalizationNegative(s: Int64, n: Int64, expS: Int64, expN: Int32) {
        let duration = Duration(seconds: s, nanoseconds: n)
        #expect(duration.seconds == expS)
        #expect(duration.nanoseconds == expN)
    }

    @Test("DurationTests: Milliseconds to Seconds normalization")
    func milliNormalization() {
        let duration: Duration = .milliseconds(1500)
        #expect(duration.seconds == 1)
        #expect(duration.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Negative nanoseconds normalization")
    func negativeNormalization() {
        // -500ms should be seconds: -1, nanos: 500,000,000
        let duration: Duration = .nanoseconds(-500_000_000)
        #expect(duration.seconds == -1)
        #expect(duration.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Large units")
    func largeUnits() {
        let duration: Duration = .weeks(1)
        #expect(duration.seconds == 604_800)
    }

    @Test("DurationTests: Double conversion")
    func doubleSeconds() {
        let duration: Duration = .seconds(2.5)
        #expect(duration.seconds == 2)
        #expect(duration.nanoseconds == 500_000_000)
    }
}

// MARK: - Timestamp Calculations

extension DurationTests {
    @Test("DurationTests: Total nanoseconds calculation")
    func timestampNanoseconds() {
        let duration = Duration(seconds: 2, nanoseconds: 500)
        // 2 * 1,000,000,000 + 500
        #expect(duration.timestampNanoseconds == 2_000_000_500)

        let negD = Duration(seconds: -1, nanoseconds: 999_999_999) // -1ns total
        #expect(negD.timestampNanoseconds == -1)
    }

    @Test("DurationTests: Checked timestamp overflow")
    func timestampCheckedOverflow() {
        // Near the limit of Int64.max
        // Int64.max is approx 9.22 * 10^18.
        // 10 billion seconds will definitely overflow when converted to nanos.
        let huge = Duration(seconds: 10_000_000_000, nanoseconds: 0)
        #expect(huge.timestampNanosecondsChecked == nil)

        // Valid limit check
        let valid = Duration(seconds: 9, nanoseconds: 0)
        #expect(valid.timestampNanosecondsChecked != nil)
    }

    @Test("DurationTests: Equality and Hashing")
    func equality() {
        let d1 = Duration(seconds: 1, nanoseconds: 500_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 1_500_000_000) // Normalizes to d1
        let d3 = Duration(seconds: 1, nanoseconds: 500_000_001)

        #expect(d1 == d2)
        #expect(d1 != d3)
        #expect(d1.hashValue == d2.hashValue)
    }
}

// MARK: - Comparison Tests

extension DurationTests {
    @Test("DurationTests: Positive durations")
    func positiveComparison() {
        let oneSecond = Duration(seconds: 1, nanoseconds: 0)
        let halfSecond = Duration(seconds: 0, nanoseconds: 500_000_000)
        let oneAndHalf = Duration(seconds: 1, nanoseconds: 500_000_000)

        #expect(halfSecond < oneSecond)
        #expect(oneSecond < oneAndHalf)
        #expect(oneAndHalf > halfSecond)
    }

    @Test("DurationTests: Same seconds, different nanoseconds")
    func sameSecondsComparison() {
        let d1 = Duration(seconds: 5, nanoseconds: 100)
        let d2 = Duration(seconds: 5, nanoseconds: 200)

        #expect(d1 < d2)
        #expect(d2 > d1)
        #expect(!(d1 > d2))
    }

    @Test("DurationTests: Negative durations (normalization check)")
    func negativeComparison() {
        // -1.5 seconds is represented as: seconds -2, nanos 500,000_000
        let minusOnePointFive = Duration(seconds: -1, nanoseconds: -500_000_000)

        // -1.0 seconds is represented as: seconds -1, nanos 0
        let minusOne = Duration(seconds: -1, nanoseconds: 0)

        // -0.5 seconds is represented as: seconds -1, nanos 500,000,000
        let minusPointFive = Duration(seconds: 0, nanoseconds: -500_000_000)

        #expect(minusOnePointFive < minusOne, "-1.5s should be less than -1.0s")
        #expect(minusOne < minusPointFive, "-1.0s should be less than -0.5s")
        #expect(minusPointFive < Duration(seconds: 0, nanoseconds: 0), "-0.5s should be less than zero")
    }

    @Test("DurationTests: Mixed signs")
    func mixedSigns() {
        let neg = Duration(seconds: -1, nanoseconds: 0)
        let zero = Duration(seconds: 0, nanoseconds: 0)
        let pos = Duration(seconds: 1, nanoseconds: 0)

        #expect(neg < zero)
        #expect(zero < pos)
        #expect(neg < pos)
    }

    @Test("DurationTests: Normalized equality")
    func normalizedEquality() {
        // 0s 1500ms vs 1s 500ms
        let d1 = Duration(seconds: 0, nanoseconds: 1_500_000_000)
        let d2 = Duration(seconds: 1, nanoseconds: 500_000_000)

        #expect(!(d1 < d2))
        #expect(!(d2 < d1))
        #expect(d1 <= d2)
        #expect(d1 >= d2)
    }

    @Test("DurationTests: Collection ordering")
    func sorting() {
        let d1 = Duration(seconds: -1, nanoseconds: 0)
        let d2 = Duration(seconds: 0, nanoseconds: 500)
        let d3 = Duration(seconds: 0, nanoseconds: 1000)
        let d4 = Duration(seconds: 1, nanoseconds: 0)

        let unsorted = [d3, d1, d4, d2]
        let sorted = unsorted.sorted()

        #expect(sorted == [d1, d2, d3, d4])
    }
}

// MARK: - Arithmetic Tests

extension DurationTests {
    @Test("DurationTests: Add duration and normalize the result")
    func additionNormalization() {
        let d1 = Duration(seconds: 0, nanoseconds: 600_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 600_000_000)
        let result = d1 + d2
        #expect(result.seconds == 1)
        #expect(result.nanoseconds == 200_000_000)

        var duration = Duration(seconds: 0, nanoseconds: 600_000_000)
        duration += d1
        duration += d2
        #expect(duration.seconds == 1)
        #expect(duration.nanoseconds == 800_000_000)
    }

    @Test("DurationTests: Subtract duration and normalize the result")
    func substractionNormalization() {
        let d1 = Duration(seconds: 1, nanoseconds: 200_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 600_000_000)
        let result = d1 - d2
        #expect(result.seconds == 0)
        #expect(result.nanoseconds == 600_000_000)

        var duration = Duration(seconds: 1, nanoseconds: 800_000_000)
        duration -= d1
        duration -= d2
        #expect(duration.seconds == 0)
        #expect(duration.nanoseconds == 0)
    }

    @Test("DurationTests: Negative Scaling")
    func negativeMultiplication() {
        let duration = Duration(seconds: 1, nanoseconds: 500_000_000) // 1.5s
        var result = duration * -1
        // Expected: -1.5s -> -2s + 500ms
        #expect(result.seconds == -2)
        #expect(result.nanoseconds == 500_000_000)

        result *= -1
        // Expected: 1.5s -> 1s + 500ms
        #expect(result.seconds == 1)
        #expect(result.nanoseconds == 500_000_000)
    }

    @Test("DurationTests: Negative Duration by Positive Scalar")
    func negativeDivision() {
        // -1.5s stored as -2s + 500ms
        let duration = Duration(seconds: -2, nanoseconds: 500_000_000)
        let result = duration / 2

        // Logical result: -0.75s
        // Floored Normalization: -1s + 250ms
        #expect(result.seconds == -1)
        #expect(result.nanoseconds == 250_000_000)
    }

    @Test("DurationTests: Remainder Carry")
    func divisionWithRemainder() {
        var duration = Duration(seconds: 1, nanoseconds: 0)
        duration /= 4
        #expect(duration.seconds == 0)
        #expect(duration.nanoseconds == 250_000_000)
    }

    @Test("DurationTests: Large values")
    func divisionLarge() {
        var duration = Duration(seconds: .max / 2, nanoseconds: 0)
        // Should not overflow due to reportingOverflow checks
        duration /= 1
        #expect(duration.seconds == .max / 2)
    }

    @Test("DurationTests: Division between durations")
    func durationsDivision() {
        // -1.5s stored as -2s + 500ms
        let d1 = Duration(seconds: 1, nanoseconds: 0)
        let d2 = Duration(seconds: 0, nanoseconds: 500_000_000)
        #expect(d1 / d2 == 2.0)

        let d3 = Duration(seconds: 9_467_077_800) // 300 years
        let d4 = Duration(seconds: 788_923_150) // 25 years
        #expect(d3 / d4 == 12.0)
    }
}

// MARK: - Addition Overflow Tests

extension DurationTests {
    @Test("DurationTests: Addition positive overflow (Max bound)")
    func additionPositiveOverflow() {
        let d1 = Duration(seconds: Int.max)
        let d2 = Duration(seconds: 10)

        let (result, overflow) = d1.addingReportingOverflow(d2)

        #expect(overflow)
        #expect(result.seconds == .max)
    }

    @Test("DurationTests: Addition negative overflow (Min bound)")
    func additionNegativeOverflow() {
        let d1 = Duration(seconds: Int.min)
        let d2 = Duration(seconds: -10)

        let (result, overflow) = d1.addingReportingOverflow(d2)

        #expect(overflow)
        #expect(result.seconds == .min)
    }

    @Test("DurationTests: Addition overflow by nanoseconds carry")
    func additionNanosecondCarryOverflow() {
        let d1 = Duration(seconds: Int.max, nanoseconds: 600_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 500_000_000)

        let (result, overflow) = d1.addingReportingOverflow(d2)

        #expect(overflow)
        #expect(result.seconds == .max)
        #expect(result.nanoseconds == 100_000_000)
    }

    @Test("DurationTests: Addition overflow by large nanoseconds scaling")
    func additionNanosecondsOnlyOverflow() {
        let d1 = Duration(seconds: .max, nanoseconds: 500_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 600_000_000)

        let (result, overflow) = d1.addingReportingOverflow(d2)

        // 1. totalNanos = 500_000_000 + 600_000_000 = 1_100_000_000
        // 2. extraSec = 1
        // 3. remNanos = 100.000.000
        // 4. partialSec = .max + 0 = .max (partialOverflow = false)
        // 5. finalSec = .max + 1 (finalOverflow = true)

        #expect(overflow)
        #expect(result.seconds == .max)
        #expect(result.nanoseconds == 100_000_000)
    }
}

// MARK: - Substraction Overflow Tests

extension DurationTests {
    @Test("DurationTests: Subtraction positive overflow (Max bound)")
    func subtractionPositiveOverflow() {
        let d1 = Duration(seconds: Int.max)
        let d2 = Duration(seconds: -10)

        let (result, overflow) = d1.subtractingReportingOverflow(d2)

        #expect(overflow)
        #expect(result.seconds == .max)
    }

    @Test("DurationTests: Subtraction negative overflow (Min bound)")
    func subtractionNegativeOverflow() {
        let d1 = Duration(seconds: Int.min)
        let d2 = Duration(seconds: 10)

        let (result, overflow) = d1.subtractingReportingOverflow(d2)

        #expect(overflow)
        #expect(result.seconds == .min)
    }

    @Test("DurationTests: Subtraction overflow by large nanoseconds scaling")
    func subtractionNanosecondsOnlyOverflow() {
        let d1 = Duration(seconds: .min, nanoseconds: 100_000_000)
        let d2 = Duration(seconds: 0, nanoseconds: 500_000_000)

        let (result, overflow) = d1.subtractingReportingOverflow(d2)

        // 1. totalNanos = 100_000_000 - 500_000_000 = -400_000_000
        // 2. extraSec = -1 (from floorDiv(-400_000_000, 1_000_000_000) = -1)
        // 3. remNanos = 600.000.000 (floorMod)
        // 4. partialSec = .min - 0 = .min (partialOverflow = false)
        // 5. finalSec = .min + (-1) (finalOverflow = true)

        #expect(overflow)
        #expect(result.seconds == .min)
        #expect(result.nanoseconds == 600_000_000)
    }
}

// MARK: - Multiplication Overflow Tests

extension DurationTests {
    @Test("DurationTests: Multiplication positive overflow (Max bound)")
    func multiplicationPositiveOverflow() {
        let duration = Duration(seconds: Int.max / 2 + 10)

        let (result, overflow) = duration.multipliedReportingOverflow(2)

        #expect(overflow)
        #expect(result.seconds == .max)
    }

    @Test("DurationTests: Multiplication negative overflow (Min bound)")
    func multiplicationNegativeOverflow() {
        let duration = Duration(seconds: Int.min / 2 - 10)

        let (result, overflow) = duration.multipliedReportingOverflow(-2)

        #expect(overflow)
        #expect(result.seconds == .max)
    }

    @Test("DurationTests: Positive * negative overflow")
    func multiplicationPositiveNegativeOverflow() {
        let duration = Duration(seconds: Int.max / 2 + 10)

        let (result, overflow) = duration.multipliedReportingOverflow(-2)

        #expect(overflow)
        #expect(result.seconds == .min)
    }

    @Test("DurationTests: Multiplication overflow by large nanoseconds scaling")
    func multiplicationNanosecondsOnlyOverflow() {
        let duration = Duration(seconds: 0, nanoseconds: 500_000_000)

        let (result, overflow) = duration.multipliedReportingOverflow(Int.max)

        #expect(overflow)
        #expect(result.seconds == .max)
    }

    @Test("DurationTests: Verify clamping behavior instead of crash")
    func operatorClampingVerification() {
        let d1 = Duration(seconds: Int.max)
        let d2 = Duration(seconds: Int.max)

        let sum = d1 + d2
        #expect(sum.seconds == .max)

        let product = d1 * 2
        #expect(product.seconds == .max)
    }
}
