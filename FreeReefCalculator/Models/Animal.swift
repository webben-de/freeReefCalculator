import SwiftData
import Foundation

@Model
final class Animal {
    var name: String
    var category: AnimalCategory
    var notes: String
    var addedAt: Date

    @Relationship(deleteRule: .cascade) var photos: [AnimalPhoto] = []
    var tank: Tank?

    init(name: String, category: AnimalCategory = .fish, notes: String = "") {
        self.name = name
        self.category = category
        self.notes = notes
        self.addedAt = Date()
    }
}

enum AnimalCategory: String, Codable, CaseIterable {
    case fish
    case invertebrate
    case coral
    case anemone

    var localizedName: String {
        switch self {
        case .fish:         return String(localized: "Fish", comment: "Animal category")
        case .invertebrate: return String(localized: "Invertebrate", comment: "Animal category")
        case .coral:        return String(localized: "Coral", comment: "Animal category")
        case .anemone:      return String(localized: "Anemone", comment: "Animal category")
        }
    }

    var systemImage: String {
        switch self {
        case .fish:         return "fish.fill"
        case .invertebrate: return "star.fill"
        case .coral:        return "leaf.fill"
        case .anemone:      return "sparkle"
        }
    }
}

@Model
final class AnimalPhoto {
    var imageData: Data
    var comment: String
    var takenAt: Date
    var animal: Animal?

    init(imageData: Data, comment: String = "") {
        self.imageData = imageData
        self.comment = comment
        self.takenAt = Date()
    }
}

@Model
final class TankPhoto {
    var imageData: Data
    var comment: String
    var takenAt: Date
    var tank: Tank?

    init(imageData: Data, comment: String = "") {
        self.imageData = imageData
        self.comment = comment
        self.takenAt = Date()
    }
}
