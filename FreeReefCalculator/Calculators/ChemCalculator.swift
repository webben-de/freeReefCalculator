import Foundation

// MARK: - Reagent Recipes

struct ChemReagent: Identifiable, Codable {
    let id: String
    let brand: String
    let product: String
    let target: ChemTarget
    /// mmol of target element per gram of reagent (for solid) or per ml (for liquid)
    let mmolPerUnit: Double
    let isLiquid: Bool
    let unitLabel: String  // "g" or "ml"
    let notes: String
}

enum ChemTarget: String, Codable, CaseIterable {
    case calcium
    case alkalinity
    case magnesium

    var localizedName: String {
        switch self {
        case .calcium:    return "Calcium"
        case .alkalinity: return "Alkalinity (KH)"
        case .magnesium:  return "Magnesium"
        }
    }
}

let chemReagentLibrary: [ChemReagent] = [
    // Calcium
    ChemReagent(id: "cacl2-anhydrous", brand: "Generic", product: "Calcium Chloride (anhydrous)", target: .calcium, mmolPerUnit: 9.01, isLiquid: false, unitLabel: "g", notes: "CaCl₂, 110.98 g/mol, 2 Cl per Ca"),
    ChemReagent(id: "cacl2-dihydrate", brand: "Generic", product: "Calcium Chloride (dihydrate)", target: .calcium, mmolPerUnit: 6.76, isLiquid: false, unitLabel: "g", notes: "CaCl₂·2H₂O, 147.01 g/mol"),
    ChemReagent(id: "calcium-gluconate", brand: "Generic", product: "Calcium Gluconate", target: .calcium, mmolPerUnit: 2.17, isLiquid: false, unitLabel: "g", notes: "C₁₂H₂₂CaO₁₄, 430.37 g/mol"),
    ChemReagent(id: "balling-ca", brand: "H.W. Balling", product: "Balling Light Part A (Ca)", target: .calcium, mmolPerUnit: 6.76, isLiquid: false, unitLabel: "g", notes: "CaCl₂ dihydrate based"),
    ChemReagent(id: "tropic-marin-ca", brand: "Tropic Marin", product: "K+ Calcium", target: .calcium, mmolPerUnit: 5.00, isLiquid: true, unitLabel: "ml", notes: "Liquid calcium supplement"),
    ChemReagent(id: "red-sea-ca", brand: "Red Sea", product: "Reef Foundation A (Ca)", target: .calcium, mmolPerUnit: 5.20, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "seachem-reef-calcium", brand: "Seachem", product: "Reef Calcium", target: .calcium, mmolPerUnit: 4.30, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "fauna-marin-ca", brand: "Fauna Marin", product: "Balling Part A", target: .calcium, mmolPerUnit: 6.76, isLiquid: false, unitLabel: "g", notes: "CaCl₂ dihydrate"),

    // Alkalinity
    ChemReagent(id: "nahco3", brand: "Generic", product: "Sodium Bicarbonate", target: .alkalinity, mmolPerUnit: 11.90, isLiquid: false, unitLabel: "g", notes: "NaHCO₃, 84.01 g/mol, 1 HCO₃ per molecule"),
    ChemReagent(id: "na2co3", brand: "Generic", product: "Sodium Carbonate (soda ash)", target: .alkalinity, mmolPerUnit: 18.87, isLiquid: false, unitLabel: "g", notes: "Na₂CO₃, 105.99 g/mol, 2 CO₃ = 4 meq"),
    ChemReagent(id: "balling-b", brand: "H.W. Balling", product: "Balling Light Part B (KH)", target: .alkalinity, mmolPerUnit: 11.90, isLiquid: false, unitLabel: "g", notes: "NaHCO₃ based"),
    ChemReagent(id: "tropic-marin-kh", brand: "Tropic Marin", product: "K+ Alkalinity", target: .alkalinity, mmolPerUnit: 5.10, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "red-sea-alk", brand: "Red Sea", product: "Reef Foundation B (Alk)", target: .alkalinity, mmolPerUnit: 5.40, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "seachem-reef-builder", brand: "Seachem", product: "Reef Builder", target: .alkalinity, mmolPerUnit: 8.50, isLiquid: false, unitLabel: "g", notes: "Powder"),
    ChemReagent(id: "fauna-marin-kh", brand: "Fauna Marin", product: "Balling Part B", target: .alkalinity, mmolPerUnit: 11.90, isLiquid: false, unitLabel: "g", notes: "NaHCO₃"),

    // Magnesium
    ChemReagent(id: "mgso4-anhydrous", brand: "Generic", product: "Magnesium Sulfate (anhydrous)", target: .magnesium, mmolPerUnit: 8.30, isLiquid: false, unitLabel: "g", notes: "MgSO₄, 120.37 g/mol"),
    ChemReagent(id: "mgcl2-anhydrous", brand: "Generic", product: "Magnesium Chloride (anhydrous)", target: .magnesium, mmolPerUnit: 10.49, isLiquid: false, unitLabel: "g", notes: "MgCl₂, 95.21 g/mol"),
    ChemReagent(id: "mgcl2-hexahydrate", brand: "Generic", product: "Magnesium Chloride (hexahydrate)", target: .magnesium, mmolPerUnit: 4.94, isLiquid: false, unitLabel: "g", notes: "MgCl₂·6H₂O, 203.30 g/mol"),
    ChemReagent(id: "balling-c", brand: "H.W. Balling", product: "Balling Light Part C (Mg)", target: .magnesium, mmolPerUnit: 6.50, isLiquid: false, unitLabel: "g", notes: "MgSO₄ + MgCl₂ mix"),
    ChemReagent(id: "tropic-marin-mg", brand: "Tropic Marin", product: "K+ Magnesium", target: .magnesium, mmolPerUnit: 4.80, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "red-sea-mg", brand: "Red Sea", product: "Reef Foundation C (Mg)", target: .magnesium, mmolPerUnit: 4.50, isLiquid: true, unitLabel: "ml", notes: "Liquid"),
    ChemReagent(id: "seachem-reef-advantage-mg", brand: "Seachem", product: "Reef Advantage Magnesium", target: .magnesium, mmolPerUnit: 7.00, isLiquid: false, unitLabel: "g", notes: "Powder"),
    ChemReagent(id: "fauna-marin-mg", brand: "Fauna Marin", product: "Balling Part C", target: .magnesium, mmolPerUnit: 6.50, isLiquid: false, unitLabel: "g", notes: "Mg blend")
]

// MARK: - Chemistry Calculator Engine

/// Molar masses
private let mMCa   = 40.078   // g/mol
private let mMAlk  = 61.016   // HCO3 equivalent g/mol  (1 dKH = 0.357 meq/L)
private let mMMg   = 24.305   // g/mol

/// Convert dKH to mmol/L (as HCO3 equivalents)
func dkhToMmolL(_ dkh: Double) -> Double { dkh * 0.357 }
func mmolLToDKH(_ mmol: Double) -> Double { mmol / 0.357 }

struct ChemCalculatorResult {
    let reagent: ChemReagent
    let doseAmount: Double   // grams or ml
    let unit: String
}

struct ChemCalculator {
    static func calculate(
        target: ChemTarget,
        currentMgL: Double,
        targetMgL: Double,
        volumeLiters: Double,
        reagent: ChemReagent
    ) -> ChemCalculatorResult {
        let deltaMgL = targetMgL - currentMgL
        guard deltaMgL > 0 else {
            return ChemCalculatorResult(reagent: reagent, doseAmount: 0, unit: reagent.unitLabel)
        }

        let molarMass: Double
        switch target {
        case .calcium:    molarMass = mMCa
        case .alkalinity: molarMass = mMAlk
        case .magnesium:  molarMass = mMMg
        }

        let totalMmol = (deltaMgL / molarMass) * volumeLiters
        let dose = totalMmol / reagent.mmolPerUnit

        return ChemCalculatorResult(reagent: reagent, doseAmount: dose, unit: reagent.unitLabel)
    }
}

// MARK: - Nutrient Calculator

struct NutrientProduct: Identifiable, Codable {
    let id: String
    let brand: String
    let product: String
    let target: NutrientTarget
    let mgPerMl: Double
}

enum NutrientTarget: String, Codable, CaseIterable {
    case nitrate, phosphate
    var localizedName: String { rawValue.capitalized }
}

let nutrientProductLibrary: [NutrientProduct] = [
    NutrientProduct(id: "fauna-marin-ultra-no3", brand: "Fauna Marin", product: "Ultra LPS Grow", target: .nitrate, mgPerMl: 50),
    NutrientProduct(id: "red-sea-no3-po4-x", brand: "Red Sea", product: "NO3:PO4-X", target: .nitrate, mgPerMl: 100),
    NutrientProduct(id: "seachem-denitrate", brand: "Seachem", product: "Denitrate", target: .nitrate, mgPerMl: 80),
    NutrientProduct(id: "brightwell-nitrat-r", brand: "Brightwell Aquatics", product: "Nitrat-R", target: .nitrate, mgPerMl: 120),
    NutrientProduct(id: "fauna-marin-ultra-po4", brand: "Fauna Marin", product: "Ultra LPS Grow", target: .phosphate, mgPerMl: 20),
    NutrientProduct(id: "seachem-phosguard", brand: "Seachem", product: "PhosGuard", target: .phosphate, mgPerMl: 15),
    NutrientProduct(id: "red-sea-no3-po4-x-po4", brand: "Red Sea", product: "NO3:PO4-X", target: .phosphate, mgPerMl: 40)
]

struct NutrientCalculator {
    /// Returns ml to add to reduce current level to target
    static func dose(currentMgL: Double, targetMgL: Double, volumeLiters: Double, product: NutrientProduct) -> Double {
        let delta = currentMgL - targetMgL
        guard delta > 0 else { return 0 }
        let totalMg = delta * volumeLiters
        return totalMg / product.mgPerMl
    }
}
