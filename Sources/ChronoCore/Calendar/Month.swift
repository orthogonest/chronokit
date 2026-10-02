public enum Month: Int, CaseIterable, Equatable, Hashable, Sendable {
    case january = 1
    case february = 2
    case march = 3
    case april = 4
    case may = 5
    case june = 6
    case july = 7
    case august = 8
    case september = 9
    case october = 10
    case november = 11
    case december = 12
}

extension Month: Comparable {
    @inlinable
    public static func < (lhs: Month, rhs: Month) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Month {
    @usableFromInline
    internal static let _cachedAllCases: [Self] = Array(Self.allCases)

    @inlinable
    func next() -> Month {
        let currentIndex = rawValue - 1
        let nextIndex = (currentIndex + 1) % 12
        return Self._cachedAllCases[nextIndex]
    }

    @inlinable
    func prev() -> Month {
        let currentIndex = rawValue - 1
        let prevIndex = (currentIndex + 11) % 12
        return Self._cachedAllCases[prevIndex]
    }
}
