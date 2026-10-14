import WidgetKit
import SwiftUI
import Foundation

// MARK: - Sessions widget

struct SessionsView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SessionsEntry

    private var next: SessionState {
        entry.states.min { $0.nextChange < $1.nextChange } ?? entry.states[0]
    }

    var body: some View {
        switch family {
        case .systemSmall: small
        case .systemMedium: medium
        default: large
        }
    }

    private var small: some View {
        WidgetShell {
            VStack(spacing: 11) {
                Text(next.name.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2.4)
                    .foregroundStyle(.white.opacity(0.45))
                CountdownRing(progress: next.progress,
                              interval: Fmt.safeInterval(entry.date, next.nextChange))
                Text("\(next.label) · \(next.localTime) local")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var medium: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "Market Sessions", right: "you \(Fmt.hourMinute(entry.date))")
                    .padding(.bottom, 6)
                ForEach(entry.states) { s in
                    SessionRow(state: s, now: entry.date)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var large: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "Market Sessions", right: "you \(Fmt.hourMinute(entry.date))")
                HStack(spacing: 22) {
                    CountdownRing(progress: next.progress,
                                  interval: Fmt.safeInterval(entry.date, next.nextChange),
                                  diameter: 100)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(next.name) \(next.label)")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.56))
                        Text("\(next.localTime) local time")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.56))
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 12)
                ForEach(entry.states) { s in
                    SessionRow(state: s, now: entry.date)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct SessionRow: View {
    let state: SessionState
    let now: Date

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack(spacing: 10) {
                Circle()
                    .fill(state.isOpen ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 5, height: 5)
                    .shadow(color: state.isOpen ? Color.white.opacity(0.5) : .clear, radius: 4)
                Text(state.name)
                    .font(.system(size: 12.5))
                    .foregroundStyle(state.isOpen ? Color.white : Color.white.opacity(0.3))
                Spacer(minLength: 4)
                Text(timerInterval: Fmt.safeInterval(now, state.nextChange), countsDown: true, showsHours: true)
                    .font(.system(size: 12.5))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .frame(width: 64, alignment: .trailing)
                Text(state.localTime)
                    .font(.system(size: 11))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.56))
                    .frame(width: 40, alignment: .trailing)
            }
            .padding(.vertical, 7)
        }
    }
}

// MARK: - News widget

enum NewsRowItem: Identifiable {
    case day(String)
    case event(FxEvent)
    var id: String {
        switch self {
        case .day(let d):    return "day-\(d)"
        case .event(let e):  return e.id
        }
    }
}

struct NewsView: View {
    @Environment(\.widgetFamily) private var family
    let entry: NewsEntry

    var body: some View {
        switch family {
        case .systemSmall: small
        case .systemMedium: medium
        default: large
        }
    }

    private var small: some View {
        Group {
            if let e = entry.events.first {
                WidgetShell {
                    VStack(alignment: .leading, spacing: 9) {
                        LabelRow(title: "Next Event")
                        Text("\(Fmt.code(e.country)) · \(e.impact)")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.56))
                        Text(e.title)
                            .font(.system(size: 15))
                            .lineLimit(2)
                        Text(timerInterval: Fmt.safeInterval(entry.date, max(entry.date, e.dateValue)),
                             countsDown: true, showsHours: true)
                            .font(.system(size: 25, weight: .thin))
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                        Text("\(Fmt.hourMinute(e.dateValue)) local")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.56))
                    }
                }
            } else {
                WidgetShell {
                    Text("No upcoming events")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    private var medium: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "Forex News", right: "next up").padding(.bottom, 6)
                ForEach(Array(entry.events.prefix(3))) { e in
                    NewsRow(event: e, now: entry.date)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var large: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "Forex Calendar", right: "countdown · local")
                ForEach(newsItems) { item in
                    switch item {
                    case .day(let d):
                        Text(d.uppercased())
                            .font(.system(size: 9, weight: .semibold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.3))
                            .padding(.top, 12)
                            .padding(.bottom, 2)
                    case .event(let e):
                        NewsRow(event: e, now: entry.date)
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var newsItems: [NewsRowItem] {
        var out: [NewsRowItem] = []
        var last = ""
        for e in entry.events.prefix(9) {
            let d = Fmt.dayLabel(e.dateValue)
            if d != last { out.append(.day(d)); last = d }
            out.append(.event(e))
        }
        return out
    }
}

struct NewsRow: View {
    let event: FxEvent
    let now: Date

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack(spacing: 8) {
                Circle()
                    .fill(event.impact == "High" ? Color.white
                          : (event.impact == "Medium" ? Color.clear : Color.white.opacity(0.2)))
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: event.impact == "Medium" ? 1.5 : 0))
                    .frame(width: 5, height: 5)
                Text(Fmt.code(event.country))
                    .font(.system(size: 9.5))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.42))
                Text(event.title)
                    .font(.system(size: 12.5))
                    .lineLimit(1)
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timerInterval: Fmt.safeInterval(now, max(now, event.dateValue)),
                         countsDown: true, showsHours: true)
                        .font(.system(size: 12))
                        .monospacedDigit()
                    Text(Fmt.hourMinute(event.dateValue))
                        .font(.system(size: 9.5))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Rates widget

struct RatesView: View {
    @Environment(\.widgetFamily) private var family
    let entry: RatesEntry

    private let pairs = ["EUR", "GBP", "JPY", "AUD", "CHF", "CAD"]

    var body: some View {
        if family == .systemMedium { medium } else { small }
    }

    private var small: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "USD / Majors").padding(.bottom, 4)
                ForEach(Array(pairs.prefix(3)), id: \.self) { p in
                    RateRow(pair: p, value: entry.rates[p])
                }
                Spacer(minLength: 0)
            }
        }
    }

    private var medium: some View {
        WidgetShell {
            VStack(alignment: .leading, spacing: 0) {
                LabelRow(title: "USD / Majors").padding(.bottom, 4)
                HStack(alignment: .top, spacing: 22) {
                    VStack(spacing: 0) {
                        ForEach(Array(pairs.prefix(3)), id: \.self) { p in
                            RateRow(pair: p, value: entry.rates[p])
                        }
                    }
                    VStack(spacing: 0) {
                        ForEach(Array(pairs.suffix(3)), id: \.self) { p in
                            RateRow(pair: p, value: entry.rates[p])
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}

struct RateRow: View {
    let pair: String
    let value: Double?

    private var text: String {
        guard let v = value else { return "—" }
        return String(format: v < 10 ? "%.4f" : "%.2f", v)
    }

    var body: some View {
        VStack(spacing: 0) {
            Hairline()
            HStack {
                Text("USD\(pair)")
                    .font(.system(size: 12.5))
                    .foregroundStyle(.white.opacity(0.9))
                Spacer(minLength: 8)
                Text(text)
                    .font(.system(size: 12.5))
                    .monospacedDigit()
            }
            .padding(.vertical, 7.5)
        }
    }
}

// MARK: - Verse widget

struct VerseView: View {
    @Environment(\.widgetFamily) private var family
    let entry: VerseEntry

    var body: some View {
        switch family {
        case .systemSmall:
            WidgetShell {
                VStack(alignment: .leading, spacing: 12) {
                    Text(trimmed(entry.verse.text, 88))
                        .font(.system(size: 15, design: .serif))
                        .lineSpacing(2)
                    LabelRow(title: entry.verse.reference)
                }
            }
        default:
            WidgetShell {
                VStack(alignment: .leading, spacing: 14) {
                    LabelRow(title: "Verse of the Day")
                    Text(entry.verse.text)
                        .font(.system(size: family == .systemLarge ? 23 : 18, design: .serif))
                        .lineSpacing(4)
                    Spacer(minLength: 0)
                    LabelRow(title: entry.verse.reference)
                }
            }
        }
    }

    private func trimmed(_ s: String, _ n: Int) -> String {
        guard s.count > n else { return s }
        return String(s.prefix(n)).trimmingCharacters(in: .whitespaces) + "…"
    }
}

// MARK: - Widget definitions

struct SessionsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SessionsWidget", provider: SessionsProvider()) { entry in
            SessionsView(entry: entry)
        }
        .configurationDisplayName("Market Sessions")
        .description("Live countdowns to every FX session open and close, in the exchange's local time.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct NewsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NewsWidget", provider: NewsProvider()) { entry in
            NewsView(entry: entry)
        }
        .configurationDisplayName("Forex News")
        .description("Countdowns to the upcoming high and medium impact economic events.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct RatesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RatesWidget", provider: RatesProvider()) { entry in
            RatesView(entry: entry)
        }
        .configurationDisplayName("FX Rates")
        .description("Live USD exchange rates for the major pairs.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct VerseWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "VerseWidget", provider: VerseProvider()) { entry in
            VerseView(entry: entry)
        }
        .configurationDisplayName("Verse of the Day")
        .description("A daily Bible verse.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        SessionsWidget()
        NewsWidget()
        RatesWidget()
        VerseWidget()
    }
}
