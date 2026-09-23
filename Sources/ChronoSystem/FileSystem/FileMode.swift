#if canImport(Darwin)
    import Darwin
#elseif canImport(Bionic)
    @preconcurrency import Bionic
#elseif canImport(Glibc)
    @preconcurrency import Glibc
#elseif canImport(Musl)
    @preconcurrency import Musl
#elseif os(Windows)
    @preconcurrency import ucrt
#elseif os(WASI)
    @preconcurrency import WASILibc
#elseif os(Emscripten)
    @preconcurrency import EmscriptenLibc
#else
    #error("Unsupported platform: Standard C library not found.")
#endif

package enum FileMode {
    case read
    case writeCreateTruncate
}

extension FileMode {
    var flags: Int32 {
        switch self {
        case .read:
            return O_RDONLY
        case .writeCreateTruncate:
            return O_WRONLY | O_CREAT | O_TRUNC
        }
    }

    #if os(Windows)
        var mode: mode_t {
            switch self {
            case .read: return 0
            case .writeCreateTruncate: return 0x0100 | 0x0080
            }
        }
    #else
        var mode: mode_t {
            switch self {
            case .read: return 0
            case .writeCreateTruncate: return 0o644
            }
        }
    #endif
}
