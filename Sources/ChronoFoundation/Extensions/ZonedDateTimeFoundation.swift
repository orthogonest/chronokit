import ChronoCore
import Foundation

public extension ChronoCore.ZonedDateTime {
    @inlinable
    init?(foundation components: Foundation.DateComponents, timeZone: ChronoCore.TimeZone) {
        guard let plainDateTime = ChronoCore.PlainDateTime(foundation: components),
              let instant = plainDateTime.instant(in: timeZone, resolving: .preferEarlier) else { return nil }
        self.init(instant: instant, timeZone: timeZone)
    }

    @inlinable
    init(foundation date: Foundation.Date, timeZone: ChronoCore.TimeZone) {
        let instant = ChronoCore.Instant(foundation: date)
        self.init(instant: instant, timeZone: timeZone)
    }
}

public extension Foundation.DateComponents {
    @inlinable
    init(chrono dateTime: ChronoCore.ZonedDateTime) {
        self.init(chrono: dateTime.plainDateTime, timeZone: dateTime.timeZone)
    }
}

public extension Foundation.Date {
    @inlinable
    init(chrono dateTime: ChronoCore.ZonedDateTime) {
        self.init(chrono: dateTime.instant)
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.ZonedDateTime {
    @inlinable
    var components: Foundation.DateComponents {
        return Foundation.DateComponents(chrono: base)
    }

    @inlinable
    var date: Foundation.Date {
        return Foundation.Date(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.DateComponents {
    @inlinable
    func zonedDateTime(timeZone: ChronoCore.TimeZone) -> ChronoCore.ZonedDateTime? {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.Date {
    @inlinable
    func zonedDateTime(timeZone: ChronoCore.TimeZone) -> ChronoCore.ZonedDateTime {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone)
    }
}
