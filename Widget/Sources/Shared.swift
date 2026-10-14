import SwiftUI
import WidgetKit

// MARK: - Reusable widget views (widget-extension only)

struct WidgetShell<Content: View>: View {
    var pad: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(pad)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.45), radius: 8, y: 1)
            .containerBackground(for: .widget) { Color.clear }
    }
}

struct CountdownRing: View {
    let progress: Double
    let interval: ClosedRange<Date>
    var diameter: CGFloat = 118

    var body: some View {
        ZStack {
            Circle().stroke(Color.white.opacity(0.13), lineWidth: 2)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(timerInterval: interval, countsDown: true, showsHours: true)
                .font(.system(size: diameter * 0.19, weight: .thin))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: diameter * 0.74)
        }
        .frame(width: diameter, height: diameter)
    }
}

struct CountdownBar: View {
    let progress: Double
    let interval: ClosedRange<Date>
    var big: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(timerInterval: interval, countsDown: true, showsHours: true)
                .font(.system(size: big ? 30 : 26, weight: .thin))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.14))
                    Capsule().fill(Color.white.opacity(0.9))
                        .frame(width: geo.size.width * min(max(progress, 0), 1))
                }
            }
            .frame(height: 2)
        }
    }
}

struct LabelRow: View {
    let title: String
    var right: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(2.4)
                .foregroundStyle(.white.opacity(0.42))
            Spacer(minLength: 4)
            if let right {
                Text(right)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.30))
            }
        }
    }
}

struct Hairline: View {
    var body: some View {
        Rectangle().fill(Color.white.opacity(0.075)).frame(height: 1)
    }
}
