import Foundation

// MARK: - Salt Mixes

struct SaltMix: Identifiable, Codable {
    let id: String
    let brand: String
    let product: String
    /// kg of mix needed to make 1 L at S.G. 1.025 (35 ppt)
    let kgPerLiterAt1025: Double

    var displayName: String { "\(brand) – \(product)" }
}

let saltMixLibrary: [SaltMix] = [
    SaltMix(id: "instant-ocean", brand: "Instant Ocean", product: "Sea Salt", kgPerLiterAt1025: 0.0357),
    SaltMix(id: "reef-crystals", brand: "Instant Ocean", product: "Reef Crystals", kgPerLiterAt1025: 0.0360),
    SaltMix(id: "red-sea-coral-pro", brand: "Red Sea", product: "Coral Pro Salt", kgPerLiterAt1025: 0.0370),
    SaltMix(id: "red-sea-blue-bucket", brand: "Red Sea", product: "Sea Salt", kgPerLiterAt1025: 0.0355),
    SaltMix(id: "tropic-marin-pro", brand: "Tropic Marin", product: "Pro-Reef Sea Salt", kgPerLiterAt1025: 0.0358),
    SaltMix(id: "tropic-marin-classic", brand: "Tropic Marin", product: "Classic Sea Salt", kgPerLiterAt1025: 0.0354),
    SaltMix(id: "fauna-marin-balling", brand: "Fauna Marin", product: "Balling Salt", kgPerLiterAt1025: 0.0352),
    SaltMix(id: "nyos-quantum", brand: "Nyos", product: "Quantum Salt", kgPerLiterAt1025: 0.0362),
    SaltMix(id: "aquaforest-reef", brand: "Aquaforest", product: "Reef Salt", kgPerLiterAt1025: 0.0365),
    SaltMix(id: "aquaforest-natural", brand: "Aquaforest", product: "Natural Sea Water Salt", kgPerLiterAt1025: 0.0358),
    SaltMix(id: "fritz-rpm", brand: "Fritz", product: "RPM Reef Pro Mix", kgPerLiterAt1025: 0.0368),
    SaltMix(id: "fritz-complete", brand: "Fritz", product: "Complete Marine Salt", kgPerLiterAt1025: 0.0354),
    SaltMix(id: "brightwell-neomarine", brand: "Brightwell Aquatics", product: "NeoMarine", kgPerLiterAt1025: 0.0361),
    SaltMix(id: "seachem-reef", brand: "Seachem", product: "Reef Salt", kgPerLiterAt1025: 0.0358),
    SaltMix(id: "kent-marine", brand: "Kent Marine", product: "Sea Salt", kgPerLiterAt1025: 0.0353),
    SaltMix(id: "two-little-fishies", brand: "Two Little Fishies", product: "AcroPower Salt", kgPerLiterAt1025: 0.0360),
    SaltMix(id: "esv", brand: "ESV", product: "B-Ionic Seawater System", kgPerLiterAt1025: 0.0356),
    SaltMix(id: "continuum", brand: "Continuum Aquatics", product: "Reef Bio Mineral Plus", kgPerLiterAt1025: 0.0363),
    SaltMix(id: "hw-korallin", brand: "H.W. Wiegandt", product: "Reefer Salt", kgPerLiterAt1025: 0.0357),
    SaltMix(id: "sangokai", brand: "Sangokai", product: "Sango Salt", kgPerLiterAt1025: 0.0362)
]

// MARK: - Salt Calculator Engine

enum SaltCalcMode {
    case adjustSalinity  // change current S.G. to target S.G.
    case waterChange     // prepare water change volume at target S.G.
}

struct SaltCalculatorResult {
    let saltGrams: Double
    let waterToAddLiters: Double?
    let mode: SaltCalcMode
}

struct SaltCalculator {
    static func calculate(
        mode: SaltCalcMode,
        currentSG: Double,
        targetSG: Double,
        volumeLiters: Double,
        mix: SaltMix
    ) -> SaltCalculatorResult {
        // Convert S.G. to salinity ppt: ppt ≈ (S.G. - 1) * 1000 / 0.7
        func sgToPpt(_ sg: Double) -> Double { (sg - 1.0) * 1000.0 / 0.7 }
        func pptToKgPerLiter(_ ppt: Double) -> Double { ppt / 1000.0 * mix.kgPerLiterAt1025 / 0.035 }

        switch mode {
        case .adjustSalinity:
            let currentPpt = sgToPpt(currentSG)
            let targetPpt = sgToPpt(targetSG)
            let deltaPpt = targetPpt - currentPpt
            if deltaPpt <= 0 {
                // Need to dilute — add fresh water
                let dilutionVolume = volumeLiters * (currentPpt / targetPpt - 1.0)
                return SaltCalculatorResult(saltGrams: 0, waterToAddLiters: dilutionVolume, mode: mode)
            } else {
                let saltKg = volumeLiters * deltaPpt / 1000.0 * mix.kgPerLiterAt1025 / 0.035
                return SaltCalculatorResult(saltGrams: saltKg * 1000, waterToAddLiters: nil, mode: mode)
            }

        case .waterChange:
            let targetPpt = sgToPpt(targetSG)
            let saltKg = pptToKgPerLiter(targetPpt) * volumeLiters
            return SaltCalculatorResult(saltGrams: saltKg * 1000, waterToAddLiters: nil, mode: mode)
        }
    }
}
