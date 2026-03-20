import SwiftData
import Foundation

@Model
final class WaterParameter {
    var timestamp: Date
    var notes: String

    // Temperature
    var temperatureCelsius: Double?

    // Salinity
    var specificGravity: Double?   // e.g. 1.025
    var salinityPpt: Double?       // parts per thousand

    // pH
    var pH: Double?

    // Calcium (mg/L)
    var calcium: Double?

    // Alkalinity
    var alkalinityDKH: Double?     // dKH / °dH
    var alkalinityMeqL: Double?    // meq/L

    // Magnesium (mg/L)
    var magnesium: Double?

    // Nutrients
    var nitrate: Double?           // NO3 mg/L
    var nitrite: Double?           // NO2 mg/L
    var phosphate: Double?         // PO4 mg/L
    var ammonia: Double?           // NH4 mg/L

    // Optional extras
    var iodine: Double?
    var potassium: Double?
    var strontium: Double?
    var silicate: Double?
    var oxygen: Double?

    var tank: Tank?

    init(timestamp: Date = Date(), notes: String = "") {
        self.timestamp = timestamp
        self.notes = notes
    }
}
