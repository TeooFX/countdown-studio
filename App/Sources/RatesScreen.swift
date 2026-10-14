import SwiftUI

struct RatesScreen: View {
    @State private var rates: [String: Double] = [:]
    @State private var updated: Date?
    @State private var loading = false
    @State private var error: String?

    private let majors: [(String, String)] = [
        ("EUR", "Euro"),
        ("GBP", "British Pound"),
        ("JPY", "Japanese Yen"),
        ("AUD", "Australian Dollar"),
        ("CAD", "Canadian Dollar"),
        ("CHF", "Swiss Franc"),
        ("CNY", "Chinese Yuan"),
        ("NZD", "New Zealand Dollar"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if loading && rates.isEmpty {
                    ProgressView().tint(.white).padding(.top, 70)
                } else if let error, rates.isEmpty {
                    MessageView(icon: "wifi.exclamationmark", text: error, actionTitle: "Retry") {
                        Task { await load() }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeader(title: "USD exchange rates")
                        StudioCard {
                            VStack(spacing: 0) {
                                ForEach(majors.indices, id: \.self) { index in
                                    RateRowView(code: majors[index].0,
                                                name: majors[index].1,
                                                value: rates[majors[index].0])
                                    if index < majors.count - 1 { RowDivider() }
                                }
                            }
                        }
                        if let updated {
                            Text("Updated \(Fmt.hourMinute(updated)) · source open.er-api.com")
                                .font(.system(size: 11))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
            .studioBackground()
            .navigationTitle("FX Rates")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await load() }
            .task { if rates.isEmpty { await load() } }
        }
    }

    private func load() async {
        loading = true
        error = nil
        do {
            rates = try await Feed.rates()
            updated = Date()
        } catch {
            self.error = "Couldn’t load exchange rates. Pull down to retry."
        }
        loading = false
    }
}

struct RateRowView: View {
    let code: String
    let name: String
    let value: Double?

    private var text: String {
        guard let v = value else { return "—" }
        return String(format: v < 10 ? "%.4f" : "%.2f", v)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("USD")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Text("/ \(code)")
                .font(.system(size: 15, weight: .medium))
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 1) {
                Text(text)
                    .font(.system(size: 16))
                    .monospacedDigit()
                Text(name)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.vertical, 12)
    }
}
