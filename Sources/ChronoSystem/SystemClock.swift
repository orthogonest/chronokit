#if canImport(Darwin)
    import Darwin
#elseif canImport(Bionic)
    @preconcurrency import Bionic
#elseif canImport(Glibc)
    @preconcurrency import Glibc
#elseif canImport(Musl)
    @preconcurrency import Musl
#elseif canImport(WinSDK)
    import WinSDK
#elseif os(WASI)
    @preconcurrency import WASILibc
#elseif os(Emscripten)
    @preconcurrency import EmscriptenLibc
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

import ChronoCore

public struct SystemClock: Clock {
    public static let shared: Self = .init()

    @inlinable
    public init() {}

    @inlinable
    public func now() -> Instant {
        var ts = timespec()

        #if os(Linux)
            // Using the explicit clock_id_t cast ensures compatibility across different Glibc versions
            clock_gettime(Int32(CLOCK_REALTIME), &ts)
        #else
            clock_gettime(CLOCK_REALTIME, &ts)
        #endif

        return Instant(
            seconds: Int64(ts.tv_sec),
            nanoseconds: Int64(ts.tv_nsec)
        )
    }
}
