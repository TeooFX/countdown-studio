import Foundation

// MARK: - Network feeds (run inside the widget extension; no CORS restrictions natively)

struct FxEvent: Codable, Identifiable {
    let title: String
    let country: String
    let date: String
    let impact: String
    let forecast: String?
    let previous: String?

    var id: String { title + "|" + date + "|" + country }

    var dateValue: Date {
        ISO8601DateFormatter().date(from: date) ?? .distantFuture
    }

    var impactClass: String {
        switch impact {
        case "High":   return "high"
        case "Medium": return "med"
        default:       return "low"
        }
    }
}

struct VerseCodable: Codable {
    let bookname: String
    let chapter: String
    let verse: String
    let text: String
}

struct Verse {
    let reference: String
    let text: String

    static let fallback = Verse(
        reference: "John 3:16",
        text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."
    )
}

enum Feed {

    private static func get(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        var req = URLRequest(url: url)
        req.timeoutInterval = 12
        req.setValue("CountdownStudio/1.0", forHTTPHeaderField: "User-Agent")
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }

    /// https://open.er-api.com  — USD base, CORS-friendly, free.
    static func rates() async throws -> [String: Double] {
        struct Resp: Codable { let rates: [String: Double] }
        let data = try await get("https://open.er-api.com/v6/latest/USD")
        let r = try JSONDecoder().decode(Resp.self, from: data)
        return r.rates
    }

    /// https://labs.bible.org  — verse of the day.
    static func verse() async throws -> Verse {
        let data = try await get("https://labs.bible.org/api/?passage=votd&type=json&format=json")
        let arr = try JSONDecoder().decode([VerseCodable].self, from: data)
        guard let v = arr.first else { return Verse.fallback }
        let clean = v.text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Verse(reference: "\(v.bookname) \(v.chapter):\(v.verse)", text: clean)
    }

    /// Forex Factory weekly calendar. Fetched directly — works in a native app.
    static func calendar() async throws -> [FxEvent] {
        let data = try await get("https://nfs.faireconomy.media/ff_calendar_thisweek.json")
        return try JSONDecoder().decode([FxEvent].self, from: data)
    }
}
