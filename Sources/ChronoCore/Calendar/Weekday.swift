public enum Weekday: Int, CaseIterable, Equatable, Hashable, Sendable {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
}

extension Weekday: Comparable {
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public extension Weekday {
    @usableFromInline
    internal static let _cachedAllCases: [Self] = Array(Self.allCases)

    @inlinable
    func next() -> Self {
        let nextIndex = (rawValue + 1) % 7
        return Self._cachedAllCases[nextIndex]
    }

    @inlinable
    func prev() -> Self {
        let prevIndex = (rawValue + 6) % 7
        return Self._cachedAllCases[prevIndex]
    }
}

public extension Weekday {
    @inlinable
    var numberFromMonday: Int {
        daysUntil(.monday) + 1
    }

    @inlinable
    var numberFromSunday: Int {
        daysUntil(.sunday) + 1
    }

    @inlinable
    var numDayFromMonday: Int {
        daysUntil(.monday)
    }

    @inlinable
    var numDayFromSunday: Int {
        daysUntil(.sunday)
    }

    @inlinable
    func daysUntil(_ other: Self) -> Int {
        (other.rawValue - rawValue + 7) % 7
    }
}
