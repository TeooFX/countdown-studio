import Foundation

// MARK: - Session model (times are LOCAL to each exchange, so DST is automatic)

struct Market: Identifiable, Hashable {
    let id: String
    let name: String
    let tzID: String
    let openMin: Int      // minutes from local midnight
    let closeMin: Int
    let isStock: Bool
}

enum Markets {
    static let all: [Market] = [
        Market(id: "sydney",   name: "Sydney",   tzID: "Australia/Sydney", openMin: 8 * 60,        closeMin: 17 * 60,      isStock: false),
        Market(id: "tokyo",    name: "Tokyo",    tzID: "Asia/Tokyo",       openMin: 9 * 60,        closeMin: 18 * 60,      isStock: false),
        Market(id: "london",   name: "London",   tzID: "Europe/London",    openMin: 8 * 60,        closeMin: 17 * 60,      isStock: false),
        Market(id: "newyork",  name: "New York", tzID: "America/New_York", openMin: 8 * 60,        closeMin: 17 * 60,      isStock: false),
        Market(id: "nyse",     name: "NYSE",     tzID: "America/New_York", openMin: 9 * 60 + 30,   closeMin: 16 * 60,      isStock: true),
    ]
}

struct SessionState: Identifiable {
    let id: String
    let name: String
    let isOpen: Bool
    let label: String        // "opens" | "closes"
    let nextChange: Date
    let progress: Double     // 0...1
    let localTime: String    // "HH:mm" in the exchange's own timezone
}

enum SessionEngine {

    static func states(at date: Date) -> [SessionState] {
        Markets.all.map { state($0, at: date) }
    }

    static func state(_ m: Market, at date: Date) -> SessionState {
        var cal = Calendar(identifier: .gregorian)
        let tz = TimeZone(identifier: m.tzID) ?? TimeZone(identifier: "UTC")!
        cal.timeZone = tz

        let c = cal.dateComponents([.hour, .minute, .second], from: date)
        let localMin = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        let isOpen = localMin >= m.openMin && localMin < m.closeMin

        let openToday  = dateAt(minutes: m.openMin,  on: date, cal: cal)
        let closeToday = dateAt(minutes: m.closeMin, on: date, cal: cal)

        var nextChange: Date
        var progress: Double

        if isOpen {
            nextChange = closeToday
            let dur = max(1, m.closeMin - m.openMin)
            progress = Double(localMin - m.openMin) / Double(dur)
        } else {
            if localMin < m.openMin {
                nextChange = openToday
            } else {
                nextChange = cal.date(byAdding: .day, value: 1, to: openToday) ?? openToday
            }
            let prevClose: Date
            if localMin >= m.closeMin {
                prevClose = closeToday
            } else {
                prevClose = cal.date(byAdding: .day, value: -1, to: closeToday) ?? closeToday
            }
            let span = nextChange.timeIntervalSince(prevClose)
            progress = span > 0 ? date.timeIntervalSince(prevClose) / span : 0
        }

        let df = DateFormatter()
        df.timeZone = tz
        df.dateFormat = "HH:mm"

        return SessionState(
            id: m.id,
            name: m.name,
            isOpen: isOpen,
            label: isOpen ? "closes" : "opens",
            nextChange: nextChange,
            progress: min(max(progress, 0), 1),
            localTime: df.string(from: date)
        )
    }

    static func dateAt(minutes: Int, on date: Date, cal: Calendar) -> Date {
        var c = cal.dateComponents([.year, .month, .day], from: date)
        c.hour = minutes / 60
        c.minute = minutes % 60
        c.second = 0
        return cal.date(from: c) ?? date
    }
}

// MARK: - Formatting helpers

enum Fmt {
    static func hourMinute(_ date: Date, tz: TimeZone = .current) -> String {
        let df = DateFormatter()
        df.timeZone = tz
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }

    static func dayLabel(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE d MMM"
        return df.string(from: date)
    }

    static func code(_ ccy: String) -> String {
        switch ccy {
        case "USD": return "US"
        case "EUR": return "EU"
        case "GBP": return "GB"
        case "JPY": return "JP"
        case "AUD": return "AU"
        case "CAD": return "CA"
        case "CHF": return "CH"
        case "NZD": return "NZ"
        case "CNY": return "CN"
        case "All": return "—"
        default:    return ccy
        }
    }

    static func safeInterval(_ a: Date, _ b: Date) -> ClosedRange<Date> {
        let hi = max(a, b)
        return a ... hi
    }
}
