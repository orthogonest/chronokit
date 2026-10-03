import ChronoCalendar
import ChronoCore
import Foundation

public extension ChronoCore.ZonedDateTime {
    init?(
        foundation components: Foundation.DateComponents,
        timeZone: ChronoCore.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) {
        guard let plainDateTime = ChronoCore.PlainDateTime(foundation: components),
              let instant = plainDateTime.instant(in: timeZone, resolving: policy) else { return nil }
        self.init(
            instant: instant,
            timeZone: timeZone,
            calendar: plainDateTime.date.calendar
        )
    }

    init?(
        foundation components: Foundation.DateComponents,
        timeZone: Foundation.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) {
        self.init(foundation: components, timeZone: timeZone.chrono.timeZone, resolving: policy)
    }

    init(
        foundation date: Foundation.Date,
        timeZone: ChronoCore.TimeZone,
        calendar: ChronoCalendar.Calendar = .gregorian
    ) {
        let instant = ChronoCore.Instant(foundation: date)
        self.init(instant: instant, timeZone: timeZone, calendar: calendar)
    }

    init(
        foundation date: Foundation.Date,
        timeZone: Foundation.TimeZone,
        calendar: ChronoCalendar.Calendar = .gregorian
    ) {
        self.init(foundation: date, timeZone: timeZone.chrono.timeZone, calendar: calendar)
    }
}

public extension Foundation.DateComponents {
    init(chrono dateTime: ChronoCore.ZonedDateTime) {
        self.init(chrono: dateTime.plainDateTime, timeZone: dateTime.timeZone)
    }
}

public extension Foundation.Date {
    init(chrono dateTime: ChronoCore.ZonedDateTime) {
        self.init(chrono: dateTime.instant)
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.ZonedDateTime {
    var components: Foundation.DateComponents {
        return Foundation.DateComponents(chrono: base)
    }

    var date: Foundation.Date {
        return Foundation.Date(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.DateComponents {
    func zonedDateTime(
        timeZone: ChronoCore.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) -> ChronoCore.ZonedDateTime? {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, resolving: policy)
    }

    func zonedDateTime(
        timeZone: Foundation.TimeZone,
        resolving policy: DSTResolutionPolicy = .preferEarlier
    ) -> ChronoCore.ZonedDateTime? {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, resolving: policy)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.Date {
    func zonedDateTime(
        timeZone: ChronoCore.TimeZone,
        calendar: ChronoCalendar.Calendar = .gregorian
    ) -> ChronoCore.ZonedDateTime {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, calendar: calendar)
    }

    func zonedDateTime(
        timeZone: Foundation.TimeZone,
        calendar: ChronoCalendar.Calendar = .gregorian
    ) -> ChronoCore.ZonedDateTime {
        return ChronoCore.ZonedDateTime(foundation: base, timeZone: timeZone, calendar: calendar)
    }
}
