import WidgetKit
import SwiftUI

// MARK: - Sessions (computed locally, entries scheduled at every market open/close)

struct SessionsEntry: TimelineEntry {
    let date: Date
    let states: [SessionState]
}

struct SessionsProvider: TimelineProvider {
    func placeholder(in context: Context) -> SessionsEntry {
        SessionsEntry(date: Date(), states: SessionEngine.states(at: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (SessionsEntry) -> Void) {
        completion(SessionsEntry(date: Date(), states: SessionEngine.states(at: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SessionsEntry>) -> Void) {
        let now = Date()
        var dates: Set<Date> = [now]

        // schedule an entry at each upcoming open/close for the next several changes
        for m in Markets.all {
            var probe = now
            for _ in 0..<3 {
                let s = SessionEngine.state(m, at: probe)
                if s.nextChange > now { dates.insert(s.nextChange.addingTimeInterval(1)) }
                probe = s.nextChange.addingTimeInterval(120)
            }
        }

        let ordered = dates.sorted().prefix(12)
        let entries = ordered.map { d in
            SessionsEntry(date: d, states: SessionEngine.states(at: d))
        }
        completion(Timeline(entries: Array(entries), policy: .atEnd))
    }
}

// MARK: - News

struct NewsEntry: TimelineEntry {
    let date: Date
    let events: [FxEvent]
}

struct NewsProvider: TimelineProvider {
    func placeholder(in context: Context) -> NewsEntry {
        NewsEntry(date: Date(), events: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsEntry) -> Void) {
        Task {
            let e = (try? await Feed.calendar()) ?? []
            completion(NewsEntry(date: Date(), events: upcoming(e)))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsEntry>) -> Void) {
        Task {
            let now = Date()
            let events = (try? await Feed.calendar()).map(upcoming) ?? []
            // keep entry view-only; refresh ~every 15 min so the "next" countdowns stay current
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
            completion(Timeline(entries: [NewsEntry(date: now, events: events)], policy: .after(next)))
        }
    }

    private func upcoming(_ e: [FxEvent]) -> [FxEvent] {
        let cutoff = Date().addingTimeInterval(-1800)
        return e
            .filter { $0.dateValue > cutoff }
            .sorted { $0.dateValue < $1.dateValue }
    }
}

// MARK: - Rates

struct RatesEntry: TimelineEntry {
    let date: Date
    let rates: [String: Double]
}

struct RatesProvider: TimelineProvider {
    static let pairs = ["EUR", "GBP", "JPY", "AUD", "CHF", "CAD"]

    func placeholder(in context: Context) -> RatesEntry {
        RatesEntry(date: Date(), rates: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (RatesEntry) -> Void) {
        Task {
            let r = (try? await Feed.rates()) ?? [:]
            completion(RatesEntry(date: Date(), rates: r))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RatesEntry>) -> Void) {
        Task {
            let now = Date()
            let r = (try? await Feed.rates()) ?? [:]
            let next = now.addingTimeInterval(1800)
            completion(Timeline(entries: [RatesEntry(date: now, rates: r)], policy: .after(next)))
        }
    }
}

// MARK: - Verse

struct VerseEntry: TimelineEntry {
    let date: Date
    let verse: Verse
}

struct VerseProvider: TimelineProvider {
    func placeholder(in context: Context) -> VerseEntry {
        VerseEntry(date: Date(), verse: .fallback)
    }

    func getSnapshot(in context: Context, completion: @escaping (VerseEntry) -> Void) {
        Task {
            let v = (try? await Feed.verse()) ?? .fallback
            completion(VerseEntry(date: Date(), verse: v))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VerseEntry>) -> Void) {
        Task {
            let now = Date()
            let v = (try? await Feed.verse()) ?? .fallback
            // verse changes once a day; refresh mid-morning
            let next = Calendar.current.date(byAdding: .hour, value: 6, to: now) ?? now.addingTimeInterval(21600)
            completion(Timeline(entries: [VerseEntry(date: now, verse: v)], policy: .after(next)))
        }
    }
}
