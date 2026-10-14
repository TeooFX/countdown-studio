import SwiftUI

struct SessionsScreen: View {
    @State private var showHelp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let states = SessionEngine.states(at: context.date)
                    let next = states.min { $0.nextChange < $1.nextChange } ?? states[0]

                    VStack(alignment: .leading, spacing: 24) {
                        nextCard(next, now: context.date)
                        sessionsList(states, now: context.date)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .studioBackground()
            .navigationTitle("Countdown Studio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showHelp = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .tint(.white)
                }
            }
            .sheet(isPresented: $showHelp) { WidgetHelpSheet() }
        }
    }

    @ViewBuilder
    private func nextCard(_ s: SessionState, now: Date) -> some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Next change")
                HStack(spacing: 20) {
                    RingProgress(progress: s.progress,
                                 interval: Fmt.safeInterval(now, s.nextChange),
                                 diameter: 138)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(s.name)
                            .font(.system(size: 22, weight: .light))
                        Text("\(s.label) · \(s.localTime) local")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.55))
                        Text(s.isOpen ? "OPEN NOW" : "CLOSED")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(1.4)
                            .foregroundStyle(s.isOpen ? Color(red: 0.45, green: 0.95, blue: 0.72)
                                                      : Color.white.opacity(0.4))
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    @ViewBuilder
    private func sessionsList(_ states: [SessionState], now: Date) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "All sessions")
            StudioCard {
                VStack(spacing: 0) {
                    ForEach(Array(states.enumerated()), id: \.element.id) { index, s in
                        SessionRowView(state: s, now: now)
                        if index < states.count - 1 { RowDivider() }
                    }
                }
            }
        }
    }
}

struct SessionRowView: View {
    let state: SessionState
    let now: Date

    var body: some View {
        VStack(spacing: 9) {
            HStack(spacing: 12) {
                Circle()
                    .fill(state.isOpen ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 7, height: 7)
                Text(state.name)
                    .font(.system(size: 15))
                    .foregroundStyle(state.isOpen ? Color.white : Color.white.opacity(0.45))
                Spacer(minLength: 8)
                Text(timerInterval: Fmt.safeInterval(now, state.nextChange),
                     countsDown: true, showsHours: true)
                    .font(.system(size: 15))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .frame(width: 72, alignment: .trailing)
                Text(state.localTime)
                    .font(.system(size: 13))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 46, alignment: .trailing)
            }
            ProgressBar(progress: state.progress)
        }
        .padding(.vertical, 11)
    }
}

struct WidgetHelpSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    StepRow(n: 1, text: "Touch and hold an empty area of the Home Screen until the icons jiggle.")
                    StepRow(n: 2, text: "Tap Edit → Add Widget (or the + in the top-left).")
                    StepRow(n: 3, text: "Search “Countdown Studio”, choose a size, then tap Add Widget.")
                    StepRow(n: 4, text: "Countdowns tick live and the data refreshes automatically.")
                }
                .padding(22)
            }
            .studioBackground()
            .navigationTitle("Add a widget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.tint(.white)
                }
            }
        }
    }
}
