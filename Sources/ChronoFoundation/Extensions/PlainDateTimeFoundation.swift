import ChronoCore
import Foundation

public extension ChronoCore.PlainDateTime {
    init?(foundation components: Foundation.DateComponents) {
        guard let date = ChronoCore.PlainDate(foundation: components),
              let time = ChronoCore.PlainTime(foundation: components) else { return nil }
        self.init(date: date, time: time)
    }
}

public extension Foundation.DateComponents {
    init(
        chrono dateTime: ChronoCore.PlainDateTime,
        timeZone: ChronoCore.TimeZone? = nil
    ) {
        var components = Self()
        components.year = dateTime.year
        components.month = dateTime.month
        components.day = dateTime.day
        components.hour = dateTime.hour
        components.minute = dateTime.minute
        components.second = dateTime.second
        components.nanosecond = dateTime.nanosecond
        components.timeZone = timeZone?.foundation.timeZone
        components.calendar = dateTime.date.calendar.foundation
        self = components
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.PlainDateTime {
    var components: Foundation.DateComponents {
        Foundation.DateComponents(chrono: base)
    }

    func components(in timeZone: ChronoCore.TimeZone?) -> Foundation.DateComponents {
        Foundation.DateComponents(chrono: base, timeZone: timeZone)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.DateComponents {
    var plainDateTime: ChronoCore.PlainDateTime? {
        return ChronoCore.PlainDateTime(foundation: base)
    }
}
