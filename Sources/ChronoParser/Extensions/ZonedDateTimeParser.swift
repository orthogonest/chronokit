import ChronoCore
import ChronoMath

public extension ZonedDateTime {
    @inlinable
    init?(rfc3339 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Instant.parsedRFC3339(string)

        guard let parsed else { return nil }

        self.init(
            year: parsed.date.year,
            month: parsed.date.month,
            day: parsed.date.day,
            hour: parsed.time.hour,
            minute: parsed.time.minute,
            second: parsed.time.second,
            nanosecond: Int(parsed.time.nanosecond),
            timeZone: .fixedOffset(seconds: parsed.offset)
        )
    }

    @inlinable
    init?(rfc5322 string: String) {
        let parsed: (date: ParsedDate, time: ParsedTime, offset: Int)? = Instant.parsedRFC5322(string)

        guard let parsed else { return nil }

        self.init(
            year: parsed.date.year,
            month: parsed.date.month,
            day: parsed.date.day,
            hour: parsed.time.hour,
            minute: parsed.time.minute,
            second: parsed.time.second,
            nanosecond: Int(parsed.time.nanosecond),
            timeZone: .fixedOffset(seconds: parsed.offset)
        )
    }

    @available(
        *,
        deprecated,
        renamed: "init(rfc5322:)",
        message: "Use init(rfc5322:) which provides full compatibility with RFC 2822."
    )
    @inlinable
    @inline(__always)
    init?(rfc2822 string: String) {
        self.init(rfc5322: string)
    }
}
