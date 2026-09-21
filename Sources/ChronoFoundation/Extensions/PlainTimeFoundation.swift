import ChronoCore
import Foundation

public extension ChronoCore.PlainTime {
    @inlinable
    init?(foundation components: Foundation.DateComponents) {
        guard let hour = components.hour,
              let minute = components.minute,
              let second = components.second else { return nil }

        let nanosecond = components.nanosecond ?? 0

        self.init(
            hour: hour,
            minute: minute,
            second: second,
            nanosecond: nanosecond
        )
    }
}

public extension Foundation.DateComponents {
    @inlinable
    init(chrono time: ChronoCore.PlainTime) {
        var components = Self()
        components.hour = time.hour
        components.minute = time.minute
        components.second = time.second
        components.nanosecond = time.nanosecond
        self = components
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.PlainTime {
    @inlinable
    var components: Foundation.DateComponents {
        return Foundation.DateComponents(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.DateComponents {
    @inlinable
    var plainTime: ChronoCore.PlainTime? {
        return ChronoCore.PlainTime(foundation: base)
    }
}
