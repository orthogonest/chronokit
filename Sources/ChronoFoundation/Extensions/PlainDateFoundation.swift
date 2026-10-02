import ChronoCore
import Foundation

public extension ChronoCore.PlainDate {
    init?(foundation components: Foundation.DateComponents) {
        guard let year = components.year,
              let month = components.month,
              let day = components.day else { return nil }
        self.init(year: year, month: month, day: day)
    }
}

public extension Foundation.DateComponents {
    init(chrono date: ChronoCore.PlainDate) {
        var components = Self()
        components.year = date.year
        components.month = date.month
        components.day = date.day
        self = components
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.PlainDate {
    var components: Foundation.DateComponents {
        return Foundation.DateComponents(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.DateComponents {
    var plainDate: ChronoCore.PlainDate? {
        return ChronoCore.PlainDate(foundation: base)
    }
}
