import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SessionsScreen()
                .tabItem { Label("Sessions", systemImage: "clock") }
            NewsScreen()
                .tabItem { Label("News", systemImage: "calendar") }
            RatesScreen()
                .tabItem { Label("Rates", systemImage: "dollarsign.circle") }
            VerseScreen()
                .tabItem { Label("Verse", systemImage: "book") }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
