import ChronoCore
@testable import ChronoFoundation
import Foundation
import Testing

struct BridgeTests {
    @Test("BridgeTests: FoundationInboundBridge storage and typing")
    func inboundBridgeStorage() {
        let dummy = 26
        let bridge = FoundationInboundBridge(dummy)

        #expect(bridge.base == 26, "Inbound bridge must properly store the base value")
        #expect(
            type(of: bridge) == FoundationInboundBridge<Int>.self,
            "Inbound bridge type should match generic parameter"
        )
    }

    @Test("BridgeTests: FoundationOutboundBridge storage and typing")
    func outboundBridgeStorage() {
        let dummy = "ChronoKit"
        let bridge = FoundationOutboundBridge(dummy)

        #expect(bridge.base == "ChronoKit", "Outbound bridge must properly store the base value")
        #expect(
            type(of: bridge) == FoundationOutboundBridge<String>.self,
            "Inbound bridge type should match generic parameter"
        )
    }
}
