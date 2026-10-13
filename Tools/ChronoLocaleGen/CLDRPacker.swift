import Foundation

// struct CLDRPacker {
//     private let dayKeys = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
//     private let formatStyles = ["full", "long", "medium", "short"]
//
//     func pack(_ calendar: GregorianCalendarData) -> Data {
//         var blob = Data()
//
//         blob.append(Data("CLDB".utf8)) // Magic number
//
//         var version = UInt16(1.littleEndian)
//         blob.append(Data(bytes: &version, count: 2))
//
//         var indexOffsetPlaceholder: UInt16 = 0
//         let placeholderPosition = blob.count
//         blob.append(Data(bytes: &indexOffsetPlaceholder, count: 2))
//
//         var stringPayload = Data()
//         var indexEntries: [(keyID: UInt16, offset: UInt32, length: UInt32)] = []
//
//         func appendRecord(_ text: String, for key: ChronokitCLDRKey) {
//             let stringData = Data(text.utf8)
//             let currentOffset = UInt32(stringPayload.count)
//             let length = UInt32(stringData.count)
//
//             indexEntries.append((keyID: key.rawValue, offset: currentOffset, length: length))
//             stringPayload.append(stringData)
//         }
//
//         // --- Serialize: Months (Wide, Abbreviated, and Stand-Alone variants) ---
//         for i in 1 ... 12 {
//             if let str = calendar.months["format"]?.find("wide", "\(i)") {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(i - 1))!)
//             }
//             if let str = calendar.months["format"]?.find("abbreviated", "\(i)") {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(11 + i))!)
//             }
//             if let str = calendar.months["stand-alone"]?.find("wide", "\(i)")
//                 ?? calendar.months["format"]?.find("wide", "\(i)")
//             {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(23 + i))!)
//             }
//         }
//
//         // --- Serialize: Days (Format Wide and Abbreviated structures) ---
//         for (idx, dayKey) in dayKeys.enumerated() {
//             if let str = calendar.days["format"]?.find("wide", dayKey) {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(36 + idx))!)
//             }
//             if let str = calendar.days["format"]?.find("abbreviated", dayKey) {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(43 + idx))!)
//             }
//         }
//
//         // --- Serialize: Pre-defined Style Formatting Framework Templates ---
//         for (idx, style) in formatStyles.enumerated() {
//             if let str = calendar.dateFormats[style]?.stringValue {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(50 + idx))!)
//             }
//             if let str = calendar.timeFormats[style]?.stringValue {
//                 appendRecord(str, for: ChronokitCLDRKey(rawValue: UInt16(54 + idx))!)
//             }
//         }
//
//         // --- Serialize: Historical Calendrical Chronology Eras (BC / AD) ---
//         let bcStr = calendar.eras["eraAbbr"]?.find("0") ?? calendar.eras["eraNames"]?.find("0")
//         if let str = bcStr {
//             appendRecord(str, for: .eraBc)
//         }
//         let adStr = calendar.eras["eraAbbr"]?.find("1") ?? calendar.eras["eraNames"]?.find("1")
//         if let str = adStr {
//             appendRecord(str, for: .eraAd)
//         }
//
//         // --- Serialize: Core Meridian Day Periods Indicators (AM / PM Tokens) ---
//         if let str = calendar.dayPeriods["format"]?.find("abbreviated", "am")
//             ?? calendar.dayPeriods["format"]?.find("wide", "am")
//         {
//             appendRecord(str, for: .dayPeriodAm)
//         }
//         if let str = calendar.dayPeriods["format"]?.find("abbreviated", "pm")
//             ?? calendar.dayPeriods["format"]?.find("wide", "pm")
//         {
//             appendRecord(str, for: .dayPeriodPm)
//         }
//
//         blob.append(stringPayload)
//
//         let indexTableStartOffset = UInt16(blob.count)
//
//         for entry in indexEntries {
//             var key = entry.keyID.littleEndian
//             var offset = entry.offset.littleEndian
//             var length = entry.length.littleEndian
//             blob.append(Data(bytes: &key, count: 2))
//             blob.append(Data(bytes: &offset, count: 4))
//             blob.append(Data(bytes: &length, count: 4))
//         }
//
//         var finalOffset = indexTableStartOffset.littleEndian
//         blob.replaceSubrange(
//             placeholderPosition ..< (placeholderPosition + 2),
//             with: Data(bytes: &finalOffset, count: 2)
//         )
//
//         return blob
//     }
// }
