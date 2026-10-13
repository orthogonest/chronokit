struct LocaleHeaderLayout {
    let magic: UInt32
    let version: UInt32
    let localeCount: UInt32
    let stringPoolOffset: UInt32
}

struct LocaleIndexNodeLayout {
    let localeHash: UInt32
    let blockOffset: UInt32
}

public struct LocaleBlockLayout {
    // A. Date/Time Format Styles (12 * 4 = 48 bytes)
    public let dateFormatFull: UInt32
    public let dateFormatLong: UInt32
    public let dateFormatMedium: UInt32
    public let dateFormatShort: UInt32

    public let timeFormatFull: UInt32
    public let timeFormatLong: UInt32
    public let timeFormatMedium: UInt32
    public let timeFormatShort: UInt32

    public let dateTimeFormatFull: UInt32
    public let dateTimeFormatLong: UInt32
    public let dateTimeFormatMedium: UInt32
    public let dateTimeFormatShort: UInt32

    /// B. Months (12 elements * 6 variants * 4 bytes = 288 bytes)
    public let monthsFormatWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    public let monthsFormatAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    public let monthsFormatNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    public let monthsStandaloneWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    public let monthsStandaloneAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    public let monthsStandaloneNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    // C. Days (7 elements * 8 variants * 4 bytes = 224 bytes)
    // Starting from Sunday (index 0) to Saturday (index 6)
    public let daysFormatWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysFormatNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysFormatShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    public let daysStandaloneWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    public let daysStandaloneShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    // D. Eras (2 elements * 3 variants * 4 bytes = 24 bytes)
    // (BCE, CE)
    public let erasWide: (UInt32, UInt32)
    public let erasAbbreviated: (UInt32, UInt32)
    public let erasNarrow: (UInt32, UInt32)
}
