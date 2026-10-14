import SwiftUI

// MARK: - Shared app styling

extension View {
    func studioBackground() -> some View { modifier(StudioBackground()) }
}

struct StudioBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.06, blue: 0.09), .black],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            content
        }
    }
}

struct StudioCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content() }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(1.8)
            .foregroundStyle(.white.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RowDivider: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.12))
                Capsule().fill(Color.white.opacity(0.85))
                    .frame(width: geo.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 3)
    }
}

struct RingProgress: View {
    let progress: Double
    let interval: ClosedRange<Date>
    var diameter: CGFloat = 150

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.12), lineWidth: 3)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Color.white.opacity(0.9),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(timerInterval: interval, countsDown: true, showsHours: true)
                .font(.system(size: diameter * 0.2, weight: .thin))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: diameter * 0.72)
        }
        .frame(width: diameter, height: diameter)
    }
}

struct ImpactDot: View {
    let impact: String

    var body: some View {
        Circle()
            .fill(impact == "High" ? Color.white
                  : (impact == "Medium" ? Color.clear : Color.white.opacity(0.25)))
            .overlay(
                Circle().stroke(Color.white.opacity(0.6),
                                lineWidth: impact == "Medium" ? 1.5 : 0)
            )
            .frame(width: 6, height: 6)
    }
}

struct MessageView: View {
    let icon: String
    let text: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(.white.opacity(0.5))
            Text(text)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 30)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
                .tint(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 70)
    }
}

struct StepRow: View {
    let n: Int
    let text: String

    var body: some View {
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
