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

package final class Mutex: @unchecked Sendable {
    private var mutex = pthread_mutex_t()

    package init() {
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Mutex initialization failed with error: \(result)")
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    @inline(__always)
    package func withLock<T>(_ body: () throws -> T) rethrows -> T {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        return try body()
    }
}
