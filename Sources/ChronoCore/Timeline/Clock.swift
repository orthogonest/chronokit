public protocol Clock: Sendable {
    var now: Instant { get }
}
