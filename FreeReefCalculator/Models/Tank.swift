import SwiftData
import Foundation

@Model
final class Tank {
    var name: String
    var type: TankType
    var volumeLiters: Double
    var notes: String
    var createdAt: Date
    var coverPhotoData: Data?

    @Relationship(deleteRule: .cascade) var parameters: [WaterParameter] = []
    @Relationship(deleteRule: .cascade) var animals: [Animal] = []
    @Relationship(deleteRule: .cascade) var photos: [TankPhoto] = []
    @Relationship(deleteRule: .cascade) var reminders: [Reminder] = []

    init(name: String,
         type: TankType = .saltwater,
         volumeLiters: Double = 100,
         notes: String = "") {
        self.name = name
        self.type = type
        self.volumeLiters = volumeLiters
        self.notes = notes
        self.createdAt = Date()
    }
}

enum TankType: String, Codable, CaseIterable {
    case saltwater
    case freshwater

    var localizedName: String {
        switch self {
        case .saltwater: return String(localized: "Saltwater", comment: "Tank type")
        case .freshwater: return String(localized: "Freshwater", comment: "Tank type")
        }
    }
}
