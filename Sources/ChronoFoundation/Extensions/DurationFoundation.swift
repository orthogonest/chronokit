import ChronoCore
import Foundation

public extension ChronoCore.Duration {
    @inlinable
    init(foundation timeInterval: Foundation.TimeInterval) {
        let seconds = Int64(trunc(timeInterval))
        let remTimeInterval = timeInterval - Double(seconds)
        let nanoseconds = Int64(round(remTimeInterval * ChronoCore.NanoSeconds.perSecondDouble))
        self.init(seconds: seconds, nanoseconds: nanoseconds)
    }

    @inlinable
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    init(foundation duration: Swift.Duration) {
        let seconds = duration.components.seconds
        let nanoseconds = duration.components.attoseconds / ChronoCore.AttoSeconds.perNanoSecond64
        self.init(seconds: seconds, nanoseconds: nanoseconds)
    }
}

public extension Foundation.TimeInterval {
    @inlinable
    init(chrono duration: ChronoCore.Duration) {
        let seconds = Double(duration.seconds)
        let nanoseconds = Double(duration.nanoseconds) / ChronoCore.NanoSeconds.perSecondDouble
        self = seconds + nanoseconds
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public extension Swift.Duration {
    @inlinable
    init(chrono duration: ChronoCore.Duration) {
        let seconds = Self.seconds(duration.seconds)
        let nanoseconds = Self.nanoseconds(duration.nanoseconds)
        self = seconds + nanoseconds
    }
}

public extension FoundationInboundBridge where Base == ChronoCore.Duration {
    @inlinable
    var timeInterval: Foundation.TimeInterval {
        Foundation.TimeInterval(chrono: base)
    }

    @inlinable
    @available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
    var duration: Swift.Duration {
        return Swift.Duration(chrono: base)
    }
}

public extension FoundationOutboundBridge where Base == Foundation.TimeInterval {
    @inlinable
    var duration: ChronoCore.Duration {
        return ChronoCore.Duration(foundation: base)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public extension FoundationOutboundBridge where Base == Swift.Duration {
    @inlinable
    var duration: ChronoCore.Duration {
        return ChronoCore.Duration(foundation: base)
    }
}
