import ChronoCalendar
import Foundation

extension ChronoCalendar.Calendar {
    var foundation: Foundation.Calendar {
        switch self {
        case .gregorian:
            return Foundation.Calendar(identifier: .gregorian)
        }
    }
}

extension Foundation.Calendar {
    var chrono: ChronoCalendar.Calendar {
        switch identifier {
        case .gregorian:
            return .gregorian
        default:
            return .gregorian
        }
    }
}
