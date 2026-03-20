import SwiftUI
import SwiftData

struct TankDetailView: View {
    @Bindable var tank: Tank
    @State private var selectedTab: TankTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            TankDashboardView(tank: tank)
                .tabItem { Label(String(localized: "Dashboard"), systemImage: "chart.bar.fill") }
                .tag(TankTab.dashboard)

            ParameterHistoryView(tank: tank)
                .tabItem { Label(String(localized: "Parameters"), systemImage: "chart.line.uptrend.xyaxis") }
                .tag(TankTab.parameters)

            AnimalListView(tank: tank)
                .tabItem { Label(String(localized: "Animals"), systemImage: "fish.fill") }
                .tag(TankTab.animals)

            ReminderListView(tank: tank)
                .tabItem { Label(String(localized: "Reminders"), systemImage: "bell.fill") }
                .tag(TankTab.reminders)
        }
        .navigationTitle(tank.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    enum TankTab {
        case dashboard, parameters, animals, reminders
    }
}
