#if canImport(Darwin)
    import Darwin
#elseif canImport(Bionic)
    @preconcurrency import Bionic
#elseif canImport(Glibc)
    @preconcurrency import Glibc
#elseif canImport(Musl)
    @preconcurrency import Musl
#elseif os(Windows)
    import WinSDK
#elseif os(WASI)
    @preconcurrency import WASILibc
#elseif os(Emscripten)
    @preconcurrency import EmscriptenLibc
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

import ChronoCore

public struct SystemClock {
    public static let shared: Self = .init()
    private init() {}
}

extension SystemClock: Clock {
    public var now: Instant {
        #if os(Windows)
            var ft = FILETIME()
            GetSystemTimePreciseAsFileTime(&ft)

            let intervalsSince1601 = (UInt64(ft.dwHighDateTime) << 32) | UInt64(ft.dwLowDateTime)
            let total100Nanos = Int64(intervalsSince1601)
            let totalSeconds = (total100Nanos / NanoSeconds.perWindowsSecond64) - Seconds.windowsToUnixEpoch64
            let remainingNanos = (total100Nanos % NanoSeconds.perWindowsSecond64) * NanoSeconds.perWindowsInterval64

            return Instant(seconds: totalSeconds, nanoseconds: remainingNanos)
        #else
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
        #endif
    }
}
