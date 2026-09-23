import ChronoCore

public extension Instant {
    static var now: Self {
        SystemClock.shared.now
    }
}
