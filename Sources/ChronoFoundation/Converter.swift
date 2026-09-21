import ChronoCore
import Foundation

public protocol ChronoToFoundation {}

public extension ChronoToFoundation {
    @inlinable
    var foundation: FoundationInboundBridge<Self> {
        FoundationInboundBridge(self)
    }
}

public protocol FoundationToChrono {}

public extension FoundationToChrono {
    @inlinable
    var chrono: FoundationOutboundBridge<Self> {
        FoundationOutboundBridge(self)
    }
}

extension ChronoCore.Duration: ChronoToFoundation {}
extension ChronoCore.PlainDate: ChronoToFoundation {}
extension ChronoCore.PlainTime: ChronoToFoundation {}
extension ChronoCore.PlainDateTime: ChronoToFoundation {}
extension ChronoCore.Instant: ChronoToFoundation {}
extension ChronoCore.TimeZone: ChronoToFoundation {}
extension ChronoCore.ZonedDateTime: ChronoToFoundation {}

extension Foundation.DateComponents: FoundationToChrono {}
extension Foundation.Date: FoundationToChrono {}
extension Foundation.TimeInterval: FoundationToChrono {}
extension Foundation.TimeZone: FoundationToChrono {}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension Swift.Duration: FoundationToChrono {}
