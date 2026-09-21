public struct FoundationInboundBridge<Base> {
    public let base: Base

    @inlinable
    public init(_ base: Base) {
        self.base = base
    }
}

public struct FoundationOutboundBridge<Base> {
    public let base: Base

    @inlinable
    public init(_ base: Base) {
        self.base = base
    }
}
