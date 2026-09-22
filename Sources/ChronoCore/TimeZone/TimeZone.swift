public protocol TimeZoneProtocol: Equatable, Hashable, Sendable {
    /// The name of the timezone (e.g., "UTC", "+07:00")
    var identifier: String { get }

    /// Returns the offset in Duration from UTC for a specific UTC timestamp.
    func offset(for instant: Instant) -> Duration

    /// Returns the offset in Duration from plain date time.
    func offset(for plain: PlainDateTime) -> PlainOffset
}

public struct PlainOffsetMetadata: Equatable, Hashable, Sendable {
    public let duration: Duration
    public let isDST: Bool

    public init(
        duration: Duration,
        isDST: Bool
    ) {
        self.duration = duration
        self.isDST = isDST
    }
}

public extension PlainOffsetMetadata {
    static func standard(_ duration: Duration) -> Self {
        Self(duration: duration, isDST: false)
    }

    static func dst(_ duration: Duration) -> Self {
        Self(duration: duration, isDST: true)
    }
}

public enum DSTResolutionPolicy: Equatable, Hashable, Sendable {
    case preferEarlier
    case preferLater
    case strict
}

public enum PlainOffset: Equatable, Hashable, Sendable {
    case unique(PlainOffsetMetadata)
    case ambiguous(earlier: PlainOffsetMetadata, later: PlainOffsetMetadata)
    case invalid
}

public extension PlainOffset {
    @inlinable
    func resolve(using policy: DSTResolutionPolicy) -> PlainOffsetMetadata? {
        switch self {
        case let .unique(offset):
            offset

        case let .ambiguous(earlier, later):
            switch policy {
            case .preferEarlier:
                earlier
            case .preferLater:
                later
            case .strict:
                nil
            }

        case .invalid:
            nil
        }
    }
}

public enum TimeZoneSign: UInt8, Equatable, Hashable, Sendable {
    case minus = 45
    case plus = 43

    public init?(char: Character) {
        guard let char = char.utf8.first else { return nil }
        self.init(rawValue: char)
    }

    public init?(symbol: String) {
        guard symbol.count == 1, let char = symbol.utf8.first else { return nil }
        self.init(rawValue: char)
    }
}

public extension TimeZoneSign {
    @inlinable
    var multiplier: Int {
        self == .plus ? 1 : -1
    }

    @inlinable
    func apply<T: BinaryInteger>(to value: T) -> T {
        value * T(multiplier)
    }
}

public final class TimeZone: Sendable, TimeZoneProtocol {
    public let identifier: String

    @usableFromInline let offsetByInstant: @Sendable (Instant) -> Duration
    @usableFromInline let offsetByPlain: @Sendable (PlainDateTime) -> PlainOffset

    public init(
        identifier: String,
        offsetByInstant: @escaping @Sendable (Instant) -> Duration,
        offsetByPlain: @escaping @Sendable (PlainDateTime) -> PlainOffset
    ) {
        self.identifier = identifier
        self.offsetByInstant = offsetByInstant
        self.offsetByPlain = offsetByPlain
    }

    public init(_ timeZone: some TimeZoneProtocol) {
        identifier = timeZone.identifier
        offsetByInstant = timeZone.offset(for:)
        offsetByPlain = timeZone.offset(for:)
    }

    @inlinable
    public func offset(for instant: Instant) -> Duration {
        return offsetByInstant(instant)
    }

    @inlinable
    public func offset(for plain: PlainDateTime) -> PlainOffset {
        return offsetByPlain(plain)
    }
}

extension TimeZone: Equatable {
    public static func == (lhs: TimeZone, rhs: TimeZone) -> Bool {
        if lhs === rhs { return true }
        return lhs.identifier == rhs.identifier
    }
}

extension TimeZone: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
}
