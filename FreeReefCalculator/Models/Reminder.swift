import SwiftData
import Foundation

@Model
final class Reminder {
    var title: String
    var notes: String
    var frequency: ReminderFrequency
    var customIntervalDays: Int
    var nextDue: Date
    var isActive: Bool
    var tank: Tank?

    init(title: String,
         notes: String = "",
         frequency: ReminderFrequency = .weekly,
         customIntervalDays: Int = 7,
         nextDue: Date = Date()) {
        self.title = title
        self.notes = notes
        self.frequency = frequency
        self.customIntervalDays = customIntervalDays
        self.nextDue = nextDue
        self.isActive = true
    }

    func markDone() {
        let interval = frequencyInDays
        nextDue = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }

    var frequencyInDays: Int {
        switch frequency {
        case .daily:      return 1
        case .every3days: return 3
        case .weekly:     return 7
        case .biweekly:   return 14
        case .monthly:    return 30
        case .custom:     return customIntervalDays
        }
    }

    var isOverdue: Bool {
        nextDue < Date()
    }
}

enum ReminderFrequency: String, Codable, CaseIterable {
    case daily
    case every3days
    case weekly
    case biweekly
    case monthly
    case custom

    var localizedName: String {
        switch self {
        case .daily:      return String(localized: "Daily")
        case .every3days: return String(localized: "Every 3 Days")
        case .weekly:     return String(localized: "Weekly")
        case .biweekly:   return String(localized: "Every 2 Weeks")
        case .monthly:    return String(localized: "Monthly")
        case .custom:     return String(localized: "Custom")
        }
    }
}
