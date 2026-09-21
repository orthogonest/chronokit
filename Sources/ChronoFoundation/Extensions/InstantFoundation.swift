import ChronoCore
import ChronoMath
import Foundation

public extension ChronoCore.Instant {
    @inlinable
    init(foundation date: Foundation.Date) {
        let timeInterval = date.timeIntervalSince1970
        let seconds = Foundation.floor(timeInterval)
        let fractional = timeInterval - seconds
        let nanoseconds = Foundation.round(fractional * ChronoCore.NanoSeconds.perSecondDouble)
        self.init(seconds: Int64(seconds), nanoseconds: Int64(nanoseconds))
    }
}

public extension Foundation.Date {
    @inlinable
    init(chrono instant: ChronoCore.Instant) {
        let seconds = Double(instant.seconds)
        let nanoseconds = Double(instant.nanoseconds) / ChronoCore.NanoSeconds.perSecondDouble
        self.init(timeIntervalSince1970: seconds + nanoseconds)
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.Instant {
    @inlinable
    var date: Foundation.Date {
        return Foundation.Date(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.Date {
    @inlinable
    var instant: ChronoCore.Instant {
        return ChronoCore.Instant(foundation: base)
    }
}
