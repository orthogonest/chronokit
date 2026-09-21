import ChronoCore
import ChronoMath

public extension ZonedDateTime {
    @inlinable
    func rfc3339(digits: Int = 0) -> String {
        let capacity = 48
        let duration = timeZone.offset(for: instant)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    digits: digits,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC3339(
                    digits: digits,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @inlinable
    func rfc5322() -> String? {
        let capacity = 48

        guard let month = Month(rawValue: month) else { return nil }
        let weekday = Weekday(rawValue: weekday)
        let duration = timeZone.offset(for: instant)

        if #available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            return String(unsafeUninitializedCapacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    weekday: weekday,
                    month: month,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return cursor
            }
        } else {
            return withUnsafeTemporaryAllocation(of: UInt8.self, capacity: capacity) { buffer in
                let raw = UnsafeMutableRawBufferPointer(buffer)
                var cursor = 0
                self.formatRFC5322(
                    weekday: weekday,
                    month: month,
                    offset: duration,
                    into: raw,
                    at: &cursor
                )
                return String(decoding: buffer[..<cursor], as: UTF8.self)
            }
        }
    }

    @available(
        *,
        deprecated,
        renamed: "rfc5322()",
        message: "RFC 2822 is obsolete. Use `DateTime.rfc5322()` instead (per RFC 5322 Section 3.3)."
    )
    @inlinable
    @inline(__always)
    func rfc2822() -> String? {
        rfc5322()
    }
}

extension ZonedDateTime {
    @usableFromInline
    func formatRFC3339(
        digits: Int,
        offset: Duration?,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        plainDateTime.formatRFC3339(
            digits: digits,
            offset: offset,
            into: raw,
            at: &cursor
        )
    }

    @usableFromInline
    func formatRFC5322(
        weekday: Weekday?,
        month: Month,
        offset: Duration?,
        into raw: UnsafeMutableRawBufferPointer,
        at cursor: inout Int
    ) {
        plainDateTime.formatRFC5322(
            weekday: weekday,
            month: month,
            offset: offset,
            into: raw,
            at: &cursor
        )
    }
}

extension ZonedDateTime: CustomStringConvertible {
    public var description: String {
        rfc3339()
    }
}
