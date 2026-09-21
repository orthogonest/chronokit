import ChronoCore
import Foundation

public extension ChronoCore.ZonedDateTime {
    @inlinable
    init?(
        foundation components: Foundation.DateComponents,
        timeZone: ChronoCore.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) {
        guard let plainDateTime = ChronoCore.PlainDateTime(foundation: components),
              let instant = plainDateTime.instant(in: timeZone, resolving: policy) else { return nil }
        self.init(instant: instant, timeZone: timeZone)
    }

    @inlinable
    init?(
        foundation components: Foundation.DateComponents,
        timeZone: Foundation.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) {
        self.init(foundation: components, timeZone: timeZone.chrono.timeZone, resolving: policy)
    }

    @inlinable
    init(foundation date: Foundation.Date, timeZone: ChronoCore.TimeZone) {
        let instant = ChronoCore.Instant(foundation: date)
        self.init(instant: instant, timeZone: timeZone)
    }

    @inlinable
    init(foundation date: Foundation.Date, timeZone: Foundation.TimeZone) {
        self.init(foundation: date, timeZone: timeZone.chrono.timeZone)
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
    func zonedDateTime(
        timeZone: ChronoCore.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) -> ChronoCore.ZonedDateTime? {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, resolving: policy)
    }

    @inlinable
    func zonedDateTime(
        timeZone: Foundation.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) -> ChronoCore.ZonedDateTime? {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, resolving: policy)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.Date {
    @inlinable
    func zonedDateTime(timeZone: ChronoCore.TimeZone) -> ChronoCore.ZonedDateTime {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone)
    }

    @inlinable
    func zonedDateTime(timeZone: Foundation.TimeZone) -> ChronoCore.ZonedDateTime {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone)
    }
}
