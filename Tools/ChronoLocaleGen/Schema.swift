// MARK: - Chronokit Binary Key Registry

public enum ChronokitCLDRKey: UInt16, CaseIterable {
    // --- MONTHS FORMAT WIDE (0 - 11) ---
    case monthFormatWideJan = 0, monthFormatWideFeb, monthFormatWideMar, monthFormatWideApr
    case monthFormatWideMay = 4, monthFormatWideJun, monthFormatWideJul, monthFormatWideAug
    case monthFormatWideSep = 8, monthFormatWideOct, monthFormatWideNov, monthFormatWideDec

    // --- MONTHS FORMAT ABBREVIATED (12 - 23) ---
    case monthFormatAbbrJan = 12, monthFormatAbbrFeb, monthFormatAbbrMar, monthFormatAbbrApr
    case monthFormatAbbrMay = 16, monthFormatAbbrJun, monthFormatAbbrJul, monthFormatAbbrAug
    case monthFormatAbbrSep = 20, monthFormatAbbrOct, monthFormatAbbrNov, monthFormatAbbrDec

    // --- MONTHS STAND-ALONE WIDE (24 - 35) ---
    // Required for languages like Russian or Polish where grammatical cases alter standalone nouns
    case monthStandAloneWideJan = 24, monthStandAloneWideFeb, monthStandAloneWideMar, monthStandAloneWideApr
    case monthStandAloneWideMay = 28, monthStandAloneWideJun, monthStandAloneWideJul, monthStandAloneWideAug
    case monthStandAloneWideSep = 32, monthStandAloneWideOct, monthStandAloneWideNov, monthStandAloneWideDec

    // --- DAYS FORMAT WIDE (36 - 42: Sunday - Saturday) ---
    case dayFormatWideSun = 36, dayFormatWideMon, dayFormatWideTue, dayFormatWideWed
    case dayFormatWideThu = 40, dayFormatWideFri, dayFormatWideSat

    // --- DAYS FORMAT ABBREVIATED (43 - 49: Sunday - Saturday) ---
    case dayFormatAbbrSun = 43, dayFormatAbbrMon, dayFormatAbbrTue, dayFormatAbbrWed
    case dayFormatAbbrThu = 47, dayFormatAbbrFri, dayFormatAbbrSat

    // --- DATE & TIME FORMAT PATTERNS (50 - 57) ---
    case dateFormatFull = 50, dateFormatLong = 51, dateFormatMedium = 52, dateFormatShort = 53
    case timeFormatFull = 54, timeFormatLong = 55, timeFormatMedium = 56, timeFormatShort = 57

    // --- ERAS & DAY PERIODS (58 - 61) ---
    case eraBc = 58
    case eraAd = 59
    case dayPeriodAm = 60
    case dayPeriodPm = 61
}
