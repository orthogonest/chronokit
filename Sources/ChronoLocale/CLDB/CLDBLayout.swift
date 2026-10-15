import ChronoSystem

package struct CLDBLayout {
    package let header: LocaleHeaderLayout
    package let indexes: [LocaleIndexNodeLayout]
    package let blocks: [LocaleBlockLayout]
    package let stringPool: [UInt8]

    package init(
        header: LocaleHeaderLayout,
        indexes: [LocaleIndexNodeLayout],
        blocks: [LocaleBlockLayout],
        stringPool: [UInt8]
    ) {
        self.header = header
        self.indexes = indexes
        self.blocks = blocks
        self.stringPool = stringPool
    }
}

package struct LocaleHeaderLayout {
    package let magic: FixedMagic
    package let version: UInt32
    package let localeCount: UInt32
    package let stringPoolOffset: UInt32

    package init(
        magic: FixedMagic,
        version: UInt32,
        localeCount: UInt32,
        stringPoolOffset: UInt32
    ) {
        self.magic = magic
        self.version = version
        self.localeCount = localeCount
        self.stringPoolOffset = stringPoolOffset
    }
}

package struct LocaleIndexNodeLayout {
    package let localeHash: UInt32
    package let blockOffset: UInt32

    package init(
        localeHash: UInt32,
        blockOffset: UInt32
    ) {
        self.localeHash = localeHash
        self.blockOffset = blockOffset
    }
}

package struct LocaleBlockLayout {
    // Date/Time Format Styles (12 * 4 = 48 bytes)
    package let dateFormatFull: UInt32
    package let dateFormatLong: UInt32
    package let dateFormatMedium: UInt32
    package let dateFormatShort: UInt32

    package let timeFormatFull: UInt32
    package let timeFormatLong: UInt32
    package let timeFormatMedium: UInt32
    package let timeFormatShort: UInt32

    package let dateTimeFormatFull: UInt32
    package let dateTimeFormatLong: UInt32
    package let dateTimeFormatMedium: UInt32
    package let dateTimeFormatShort: UInt32

    /// Months (12 elements * 6 variants * 4 bytes = 288 bytes)
    package let monthsFormatWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsFormatAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsFormatNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    package let monthsStandaloneWide: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsStandaloneAbbreviated: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )
    package let monthsStandaloneNarrow: (
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32,
        UInt32, UInt32, UInt32, UInt32
    )

    // Days (7 elements * 8 variants * 4 bytes = 224 bytes)
    // Starting from Sunday (index 0) to Saturday (index 6)
    package let daysFormatWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysFormatShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    package let daysStandaloneWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)
    package let daysStandaloneShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)

    // Quarters (4 elements * 6 variants * 4 bytes = 96 bytes)
    package let quartersFormatWide: (UInt32, UInt32, UInt32, UInt32)
    package let quartersFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32)
    package let quartersFormatNarrow: (UInt32, UInt32, UInt32, UInt32)

    package let quartersStandaloneWide: (UInt32, UInt32, UInt32, UInt32)
    package let quartersStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32)
    package let quartersStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32)

    // Day Periods / AM-PM (2 elements [AM, PM] * 6 variants * 4 bytes = 48 bytes)
    package let dayPeriodsFormatWide: (UInt32, UInt32)
    package let dayPeriodsFormatAbbreviated: (UInt32, UInt32)
    package let dayPeriodsFormatNarrow: (UInt32, UInt32)

    package let dayPeriodsStandaloneWide: (UInt32, UInt32)
    package let dayPeriodsStandaloneAbbreviated: (UInt32, UInt32)
    package let dayPeriodsStandaloneNarrow: (UInt32, UInt32)

    // Eras / BCE-CE (2 elements * 3 variants * 4 bytes = 24 bytes)
    package let erasWide: (UInt32, UInt32)
    package let erasAbbreviated: (UInt32, UInt32)
    package let erasNarrow: (UInt32, UInt32)

    // Skeletons (2 blocks * 4 variants * 4 bytes = 32 bytes)
    package let dateSkeletonFull: UInt32
    package let dateSkeletonLong: UInt32
    package let dateSkeletonMedium: UInt32
    package let dateSkeletonShort: UInt32

    package let timeSkeletonFull: UInt32
    package let timeSkeletonLong: UInt32
    package let timeSkeletonMedium: UInt32
    package let timeSkeletonShort: UInt32

    package init(
        dateFormatFull: UInt32,
        dateFormatLong: UInt32,
        dateFormatMedium: UInt32,
        dateFormatShort: UInt32,
        timeFormatFull: UInt32,
        timeFormatLong: UInt32,
        timeFormatMedium: UInt32,
        timeFormatShort: UInt32,
        dateTimeFormatFull: UInt32,
        dateTimeFormatLong: UInt32,
        dateTimeFormatMedium: UInt32,
        dateTimeFormatShort: UInt32,
        monthsFormatWide: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsFormatAbbreviated: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsFormatNarrow: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneWide: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneAbbreviated: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        monthsStandaloneNarrow: (
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32,
            UInt32, UInt32, UInt32, UInt32
        ),
        daysFormatWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysFormatShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneWide: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        daysStandaloneShort: (UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32),
        quartersFormatWide: (UInt32, UInt32, UInt32, UInt32),
        quartersFormatAbbreviated: (UInt32, UInt32, UInt32, UInt32),
        quartersFormatNarrow: (UInt32, UInt32, UInt32, UInt32),
        quartersStandaloneWide: (UInt32, UInt32, UInt32, UInt32),
        quartersStandaloneAbbreviated: (UInt32, UInt32, UInt32, UInt32),
        quartersStandaloneNarrow: (UInt32, UInt32, UInt32, UInt32),
        dayPeriodsFormatWide: (UInt32, UInt32),
        dayPeriodsFormatAbbreviated: (UInt32, UInt32),
        dayPeriodsFormatNarrow: (UInt32, UInt32),
        dayPeriodsStandaloneWide: (UInt32, UInt32),
        dayPeriodsStandaloneAbbreviated: (UInt32, UInt32),
        dayPeriodsStandaloneNarrow: (UInt32, UInt32),
        erasWide: (UInt32, UInt32),
        erasAbbreviated: (UInt32, UInt32),
        erasNarrow: (UInt32, UInt32),
        dateSkeletonFull: UInt32,
        dateSkeletonLong: UInt32,
        dateSkeletonMedium: UInt32,
        dateSkeletonShort: UInt32,
        timeSkeletonFull: UInt32,
        timeSkeletonLong: UInt32,
        timeSkeletonMedium: UInt32,
        timeSkeletonShort: UInt32
    ) {
        self.dateFormatFull = dateFormatFull
        self.dateFormatLong = dateFormatLong
        self.dateFormatMedium = dateFormatMedium
        self.dateFormatShort = dateFormatShort

        self.timeFormatFull = timeFormatFull
        self.timeFormatLong = timeFormatLong
        self.timeFormatMedium = timeFormatMedium
        self.timeFormatShort = timeFormatShort

        self.dateTimeFormatFull = dateTimeFormatFull
        self.dateTimeFormatLong = dateTimeFormatLong
        self.dateTimeFormatMedium = dateTimeFormatMedium
        self.dateTimeFormatShort = dateTimeFormatShort

        self.monthsFormatWide = monthsFormatWide
        self.monthsFormatAbbreviated = monthsFormatAbbreviated
        self.monthsFormatNarrow = monthsFormatNarrow

        self.monthsStandaloneWide = monthsStandaloneWide
        self.monthsStandaloneAbbreviated = monthsStandaloneAbbreviated
        self.monthsStandaloneNarrow = monthsStandaloneNarrow

        self.daysFormatWide = daysFormatWide
        self.daysFormatAbbreviated = daysFormatAbbreviated
        self.daysFormatNarrow = daysFormatNarrow
        self.daysFormatShort = daysFormatShort

        self.daysStandaloneWide = daysStandaloneWide
        self.daysStandaloneAbbreviated = daysStandaloneAbbreviated
        self.daysStandaloneNarrow = daysStandaloneNarrow
        self.daysStandaloneShort = daysStandaloneShort

        self.quartersFormatWide = quartersFormatWide
        self.quartersFormatAbbreviated = quartersFormatAbbreviated
        self.quartersFormatNarrow = quartersFormatNarrow
        self.quartersStandaloneWide = quartersStandaloneWide
        self.quartersStandaloneAbbreviated = quartersStandaloneAbbreviated
        self.quartersStandaloneNarrow = quartersStandaloneNarrow

        self.dayPeriodsFormatWide = dayPeriodsFormatWide
        self.dayPeriodsFormatAbbreviated = dayPeriodsFormatAbbreviated
        self.dayPeriodsFormatNarrow = dayPeriodsFormatNarrow
        self.dayPeriodsStandaloneWide = dayPeriodsStandaloneWide
        self.dayPeriodsStandaloneAbbreviated = dayPeriodsStandaloneAbbreviated
        self.dayPeriodsStandaloneNarrow = dayPeriodsStandaloneNarrow

        self.erasWide = erasWide
        self.erasAbbreviated = erasAbbreviated
        self.erasNarrow = erasNarrow

        self.dateSkeletonFull = dateSkeletonFull
        self.dateSkeletonLong = dateSkeletonLong
        self.dateSkeletonMedium = dateSkeletonMedium
        self.dateSkeletonShort = dateSkeletonShort
        self.timeSkeletonFull = timeSkeletonFull
        self.timeSkeletonLong = timeSkeletonLong
        self.timeSkeletonMedium = timeSkeletonMedium
        self.timeSkeletonShort = timeSkeletonShort
    }
}
