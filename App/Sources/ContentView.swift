import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.09),
                                        Color.black],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Countdown Studio")
                                .font(.system(size: 30, weight: .light))
                                .foregroundStyle(.white)
                            Text("Forex sessions · economic news · verse of the day")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        .padding(.top, 8)

                        section("Sessions right now") {
                            TimelineView(.periodic(from: .now, by: 1)) { context in
                                let states = SessionEngine.states(at: context.date)
                                VStack(spacing: 0) {
                                    ForEach(states) { s in
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(s.isOpen ? Color.white : Color.white.opacity(0.2))
                                                .frame(width: 6, height: 6)
                                            Text(s.name)
                                                .font(.system(size: 15))
                                                .foregroundStyle(s.isOpen ? .white : .white.opacity(0.4))
                                            Spacer()
                                            Text(timerInterval: Fmt.safeInterval(context.date, s.nextChange),
                                                 countsDown: true, showsHours: true)
                                                .font(.system(size: 15))
                                                .monospacedDigit()
                                                .foregroundStyle(.white.opacity(0.9))
                                                .frame(width: 76, alignment: .trailing)
                                            Text(s.localTime)
                                                .font(.system(size: 13))
                                                .monospacedDigit()
                                                .foregroundStyle(.white.opacity(0.5))
                                                .frame(width: 48, alignment: .trailing)
                                        }
                                        .padding(.vertical, 11)
                                        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                                    }
                                }
                            }
                        }

                        section("Add a widget") {
                            VStack(alignment: .leading, spacing: 14) {
                                step(1, "Touch and hold an empty area of the Home Screen until it jiggles.")
                                step(2, "Tap Edit → Add Widget (or the + in the top-left).")
                                step(3, "Search “Countdown Studio”, pick a size, then tap Add Widget.")
                                step(4, "Widgets refresh automatically — countdowns tick live.")
                            }
                        }

                        Text("Sessions use each exchange's local time, so daylight-saving shifts are handled for you. News shows only high and medium impact events. Data: open.er-api.com, Forex Factory, labs.bible.org.")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.35))
                            .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.8)
                .foregroundStyle(.white.opacity(0.4))
            content()
                .padding(16)
                .background(Color.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                )
        }
    }

    @ViewBuilder
    private func step(_ n: Int, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 20, height: 20)
                .background(Circle().fill(.white))
            Text(text)
                .font(.system(size: 13.5))
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    ContentView()
}
