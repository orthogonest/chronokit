import ChronoCore
import Foundation

public extension Foundation.TimeZone {
    @inlinable
    init?(chrono timeZone: ChronoCore.TimeZone) {
        let id = timeZone.identifier

        if id.hasPrefix("+") || id.hasPrefix("-") {
            guard let tz = Self(identifier: "GMT\(id)") else { return nil }
            self = tz
            return
        }

        self.init(identifier: id)
    }
}

extension Foundation.TimeZone: ChronoCore.TimeZoneProtocol {
    @inlinable
    public func offset(for instant: ChronoCore.Instant) -> ChronoCore.Duration {
        let date = instant.foundation.date
        let offsetSeconds = Int64(secondsFromGMT(for: date))
        return ChronoCore.Duration(seconds: offsetSeconds)
    }

    @inlinable
    public func offset(for plain: ChronoCore.PlainDateTime) -> ChronoCore.PlainOffset {
        var components = plain.foundation.components
        components.timeZone = self

        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = self

        guard let date = calendar.date(from: components) else {
            return .invalid
        }

        let verifyComponent = calendar.dateComponents(in: self, from: date)
        if verifyComponent.hour != components.hour
            || verifyComponent.minute != components.minute
        {
            return .invalid
        }

        if let nextTransition = nextDaylightSavingTimeTransition(after: date),
           abs(nextTransition.timeIntervalSince(date)) <= (2 * ChronoCore.Seconds.perHourDouble)
        {
            let offsetBefore = Int64(secondsFromGMT(for: date))
            let isDSTBefore = isDaylightSavingTime(for: date)

            let dateAfter = nextTransition.addingTimeInterval(1)
            let offsetAfter = Int64(secondsFromGMT(for: dateAfter))
            let isDSTAfter = isDaylightSavingTime(for: dateAfter)

            let earlierMeta = ChronoCore.PlainOffsetMetadata(duration: .seconds(offsetBefore), isDST: isDSTBefore)
            let laterMeta = ChronoCore.PlainOffsetMetadata(duration: .seconds(offsetAfter), isDST: isDSTAfter)

            return .ambiguous(earlier: earlierMeta, later: laterMeta)
        }

        let secondsFromGMT = Int64(secondsFromGMT(for: date))
        let isDST = isDaylightSavingTime(for: date)
        let metadata = ChronoCore.PlainOffsetMetadata(duration: .seconds(secondsFromGMT), isDST: isDST)
        return .unique(metadata)
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.TimeZone {
    @inlinable
    var timeZone: Foundation.TimeZone? {
        Foundation.TimeZone(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.TimeZone {
    @inlinable
    var timeZone: ChronoCore.TimeZone {
        ChronoCore.TimeZone(base)
    }
}
