import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TankListView()
                .tabItem { Label(String(localized: "Tanks"), systemImage: "drop.fill") }

            FAQView()
                .tabItem { Label(String(localized: "Reference"), systemImage: "book.fill") }

            SettingsView()
                .tabItem { Label(String(localized: "Settings"), systemImage: "gearshape.fill") }
        }
    }
}
