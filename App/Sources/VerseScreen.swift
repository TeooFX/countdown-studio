import SwiftUI

struct VerseScreen: View {
    @State private var verse: Verse = .fallback

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Fmt.dayLabel(Date()).uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.8)
                        .foregroundStyle(.white.opacity(0.4))

                    StudioCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Text(verse.text)
                                .font(.system(size: 24, design: .serif))
                                .lineSpacing(7)
                                .foregroundStyle(.white.opacity(0.95))
                                .fixedSize(horizontal: false, vertical: true)
                            RowDivider()
                            HStack {
                                Spacer(minLength: 0)
                                Text(verse.reference)
                                    .font(.system(size: 13, weight: .medium))
                                    .tracking(0.5)
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }

                    Text("Source: labs.bible.org")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .padding(20)
            }
            .studioBackground()
            .navigationTitle("Verse of the Day")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        if let v = try? await Feed.verse() { verse = v }
    }
}
