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

public struct SystemTimeZone: TimeZoneProtocol {
    public init() {}

    #if os(Windows)
        public var identifier: String {
            var tzInfo = DYNAMIC_TIME_ZONE_INFORMATION()
            let result = GetDynamicTimeZoneInformation(&tzInfo)
            guard result != TIME_ZONE_ID_INVALID else { return "Local" }

            // Read wchar_t array (UTF-16) from TimeZoneKeyName
            let mirror = Mirror(reflecting: tzInfo.TimeZoneKeyName)
            var utf16Bytes: [UInt16] = []
            for child in mirror.children {
                if let val = child.value as? UInt16 {
                    if val == 0 { break } // Null terminator
                    utf16Bytes.append(val)
                }
            }
            return String(decoding: utf16Bytes, as: UTF16.self)
        }
    #else
        public var identifier: String {
            if let tzEnv = getenv("TZ") { return String(cString: tzEnv) }

            let path = "/etc/localtime"
            var buffer = [Int8](repeating: 0, count: 1024)
            let count = readlink(path, &buffer, buffer.count - 1)

            if count > 0 {
                let bytes = buffer.prefix(count).map { UInt8(bitPattern: $0) }
                let link = String(decoding: bytes, as: UTF8.self)
                let parts = link.split(separator: "/")

                // link example: /usr/share/zoneinfo/Asia/Jakarta
                if let zoneInfoIndex = parts.firstIndex(of: "zoneinfo"),
                   zoneInfoIndex + 1 < parts.count
                {
                    return parts[(zoneInfoIndex + 1)...].joined(separator: "/")
                }

                return parts.last.map(String.init) ?? "Local"
            }

            return "Local"
        }
    #endif

    #if os(Windows)
        public func offset(for _: Instant) -> Duration {
            var tzInfo = DYNAMIC_TIME_ZONE_INFORMATION()
            let result = GetDynamicTimeZoneInformation(&tzInfo)
            guard result != TIME_ZONE_ID_INVALID else { return .seconds(0) }

            // Win32 Bias is stored in minutes WEST of UTC (West is positive, East is negative).
            // We invert the sign to match ChronoKit's standard (East is positive) and convert to seconds.
            var totalBias = tzInfo.Bias
            if result == TIME_ZONE_ID_DAYLIGHT {
                totalBias += tzInfo.DaylightBias
            } else {
                totalBias += tzInfo.StandardBias
            }

            let offsetSeconds = Int64(-totalBias) * Int64(Seconds.perMinute)
            return .seconds(offsetSeconds)
        }
    #else
        public func offset(for instant: Instant) -> Duration {
            var tt = time_t(instant.seconds)
            var lt = tm()

            // localtime_r is thread-safe and populates 'lt' based on 'tt'
            localtime_r(&tt, &lt)

            // tm_gmtoff: seconds EAST of UTC (e.g., +07:00 is 25200)
            // Available on Darwin and Glibc/Musl.
            return .seconds(lt.tm_gmtoff)
        }
    #endif

    public func offset(for plain: PlainDateTime) -> PlainOffset {
        let rawInstant = plain.instant(offset: .utc)
        let systemOffset = offset(for: rawInstant)
        let correctedInstant = plain.instant(offset: FixedOffset(systemOffset))
        let finalOffset = offset(for: correctedInstant)
        return .unique(.standard(finalOffset))
    }
}

public extension TimeZone {
    static let system: TimeZone = .init(SystemTimeZone())
}

public extension ZonedDateTime {
    static func system(instant: Instant) -> Self {
        self.init(instant: instant, timeZone: .system)
    }
}
