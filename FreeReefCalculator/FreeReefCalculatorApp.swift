import SwiftUI
import SwiftData

@main
struct FreeReefCalculatorApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Tank.self, WaterParameter.self, Animal.self, AnimalPhoto.self, TankPhoto.self, Reminder.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
