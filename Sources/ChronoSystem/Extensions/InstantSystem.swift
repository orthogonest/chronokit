import ChronoCore

public extension Instant {
    @inlinable
    static var now: Self {
        SystemClock.shared.now()
    }
}
