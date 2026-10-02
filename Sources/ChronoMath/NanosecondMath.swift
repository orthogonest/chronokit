@usableFromInline
package enum NanosecondMath {
    @usableFromInline
    package static func span(forDigits digits: Int) -> Int64 {
        switch digits {
        case 0: 1_000_000_000
        case 1: 100_000_000
        case 2: 10_000_000
        case 3: 1_000_000
        case 4: 100_000
        case 5: 10000
        case 6: 1000
        case 7: 100
        case 8: 10
        default: 1
        }
    }
}

package extension Int {
    @usableFromInline
    var paddedTwoDigit: String {
        self < 10 ? "0\(self)" : String(self)
    }
}
