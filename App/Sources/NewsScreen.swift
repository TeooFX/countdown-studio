import SwiftUI

struct NewsScreen: View {
    @State private var events: [FxEvent] = []
    @State private var loading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                if loading && events.isEmpty {
                    ProgressView().tint(.white).padding(.top, 70)
                } else if let error, events.isEmpty {
                    MessageView(icon: "wifi.exclamationmark", text: error, actionTitle: "Retry") {
                        Task { await load() }
                    }
                } else if events.isEmpty {
                    MessageView(icon: "calendar.badge.exclamationmark",
                                text: "No high or medium impact events are scheduled this week.")
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(grouped(events)) { group in
                                SectionHeader(title: group.title).padding(.top, 6)
                                StudioCard {
                                    VStack(spacing: 0) {
                                        ForEach(Array(group.events.enumerated()), id: \.element.id) { index, e in
                                            NewsRowView(event: e, now: context.date)
                                            if index < group.events.count - 1 { RowDivider() }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 30)
                    }
                }
            }
            .studioBackground()
            .navigationTitle("Forex News")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await load() }
            .task { if events.isEmpty { await load() } }
        }
    }

    private func grouped(_ all: [FxEvent]) -> [DayGroup] {
        var order: [String] = []
        var map: [String: [FxEvent]] = [:]
        for e in all.prefix(24) {
            let key = Fmt.dayLabel(e.dateValue)
            if map[key] == nil { map[key] = []; order.append(key) }
            map[key, default: []].append(e)
        }
        return order.map { DayGroup(id: $0, title: $0, events: map[$0] ?? []) }
    }

    private func load() async {
        loading = true
        error = nil
        do {
            let cutoff = Date().addingTimeInterval(-1800)
            let raw = try await Feed.calendar()
            events = raw
                .filter { ($0.impact == "High" || $0.impact == "Medium") && $0.dateValue > cutoff }
                .sorted { $0.dateValue < $1.dateValue }
        } catch {
            self.error = "Couldn’t load the economic calendar. Pull down to retry."
        }
        loading = false
    }
}

struct DayGroup: Identifiable {
    let id: String
    let title: String
    let events: [FxEvent]
}

struct NewsRowView: View {
    let event: FxEvent
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                ImpactDot(impact: event.impact)
                Text(Fmt.code(event.country))
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.45))
                Spacer(minLength: 8)
                Text(Fmt.hourMinute(event.dateValue))
                    .font(.system(size: 12))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text(event.title)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Text(timerInterval: Fmt.safeInterval(now, max(now, event.dateValue)),
                     countsDown: true, showsHours: true)
                    .font(.system(size: 13, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                if let f = event.forecast, !f.isEmpty {
                    Text("forecast \(f)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                if let p = event.previous, !p.isEmpty {
                    Text("prev \(p)")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.4))
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 12)
    }
}
