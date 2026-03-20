import SwiftUI

struct CalculatorsView: View {
    let tank: Tank?
    @State private var selectedCalc: CalcTab = .salt

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedCalc) {
                SaltCalculatorView(tank: tank)
                    .tabItem { Label(String(localized: "Salt"), systemImage: "drop.fill") }
                    .tag(CalcTab.salt)

                ChemCalculatorView(tank: tank)
                    .tabItem { Label("Ca/KH/Mg", systemImage: "flask.fill") }
                    .tag(CalcTab.chem)

                NutrientCalculatorView(tank: tank)
                    .tabItem { Label(String(localized: "Nutrients"), systemImage: "leaf.fill") }
                    .tag(CalcTab.nutrients)
            }
            .navigationTitle(String(localized: "Calculators"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    enum CalcTab { case salt, chem, nutrients }
}

// MARK: - Salt Calculator View

struct SaltCalculatorView: View {
    let tank: Tank?

    @State private var mode: SaltCalcMode = .waterChange
    @State private var currentSGStr = "1.025"
    @State private var targetSGStr = "1.026"
    @State private var volumeStr = ""
    @State private var selectedMixIndex = 0
    @State private var result: SaltCalculatorResult?

    var selectedMix: SaltMix { saltMixLibrary[selectedMixIndex] }

    var body: some View {
        Form {
            Section(String(localized: "Mode")) {
                Picker(String(localized: "Mode"), selection: $mode) {
                    Text(String(localized: "Water Change")).tag(SaltCalcMode.waterChange)
                    Text(String(localized: "Adjust Salinity")).tag(SaltCalcMode.adjustSalinity)
                }
                .pickerStyle(.segmented)
            }

            Section(String(localized: "Parameters")) {
                if mode == .adjustSalinity {
                    HStack {
                        Text(String(localized: "Current S.G."))
                        Spacer()
                        TextField("1.025", text: $currentSGStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                    }
                }
                HStack {
                    Text(String(localized: "Target S.G."))
                    Spacer()
                    TextField("1.026", text: $targetSGStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(String(localized: "Volume (L)"))
                    Spacer()
                    TextField(tank.map { String(format: "%.0f", $0.volumeLiters) } ?? "100", text: $volumeStr)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section(String(localized: "Salt Mix")) {
                Picker(String(localized: "Product"), selection: $selectedMixIndex) {
                    ForEach(saltMixLibrary.indices, id: \.self) { i in
                        Text(saltMixLibrary[i].displayName).tag(i)
                    }
                }
                .pickerStyle(.menu)
            }

            Section {
                Button(String(localized: "Calculate")) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }

            if let result {
                Section(String(localized: "Result")) {
                    if result.saltGrams > 0 {
                        ResultRow(label: String(localized: "Salt needed"), value: String(format: "%.1f g", result.saltGrams))
                        ResultRow(label: String(localized: "≈ kg"), value: String(format: "%.3f kg", result.saltGrams / 1000))
                    }
                    if let water = result.waterToAddLiters {
                        ResultRow(label: String(localized: "Fresh water to add"), value: String(format: "%.1f L", water))
                    }
                    if result.saltGrams == 0 && result.waterToAddLiters == nil {
                        Text(String(localized: "Already at target salinity.")).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Salt Calculator"))
        .onAppear {
            if let tank { volumeStr = String(format: "%.0f", tank.volumeLiters) }
        }
    }

    private func calculate() {
        guard let currentSG = Double(currentSGStr),
              let targetSG = Double(targetSGStr),
              let volume = Double(volumeStr) else { return }
        result = SaltCalculator.calculate(mode: mode, currentSG: currentSG, targetSG: targetSG, volumeLiters: volume, mix: selectedMix)
    }
}

// MARK: - Chem Calculator View

struct ChemCalculatorView: View {
    let tank: Tank?

    @State private var target: ChemTarget = .calcium
    @State private var currentStr = ""
    @State private var targetStr = ""
    @State private var volumeStr = ""
    @State private var selectedReagentIndex = 0
    @State private var result: ChemCalculatorResult?

    var filteredReagents: [ChemReagent] {
        chemReagentLibrary.filter { $0.target == target }
    }
    var selectedReagent: ChemReagent? {
        filteredReagents.indices.contains(selectedReagentIndex) ? filteredReagents[selectedReagentIndex] : filteredReagents.first
    }

    var targetPlaceholders: (current: String, unit: String) {
        switch target {
        case .calcium:    return ("400", "mg/L")
        case .alkalinity: return ("8.0", "dKH (enter as mg/L ÷ 17.8 for dKH)")
        case .magnesium:  return ("1280", "mg/L")
        }
    }

    var body: some View {
        Form {
            Section(String(localized: "Element")) {
                Picker(String(localized: "Target"), selection: $target) {
                    ForEach(ChemTarget.allCases, id: \.self) { t in
                        Text(t.localizedName).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: target) { _, _ in selectedReagentIndex = 0; result = nil }
            }

            Section(String(localized: "Values")) {
                HStack {
                    Text(target == .alkalinity ? "Current (dKH)" : "Current (mg/L)")
                    Spacer()
                    TextField(targetPlaceholders.current, text: $currentStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(target == .alkalinity ? "Target (dKH)" : "Target (mg/L)")
                    Spacer()
                    TextField(targetPlaceholders.current, text: $targetStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(String(localized: "Volume (L)"))
                    Spacer()
                    TextField(tank.map { String(format: "%.0f", $0.volumeLiters) } ?? "100", text: $volumeStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            }

            Section(String(localized: "Reagent")) {
                Picker(String(localized: "Product"), selection: $selectedReagentIndex) {
                    ForEach(filteredReagents.indices, id: \.self) { i in
                        Text(filteredReagents[i].brand + " " + filteredReagents[i].product).tag(i)
                    }
                }
                .pickerStyle(.menu)
                if let notes = selectedReagent?.notes, !notes.isEmpty {
                    Text(notes).font(.caption).foregroundStyle(.secondary)
                }
            }

            Section {
                Button(String(localized: "Calculate")) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }

            if let result {
                Section(String(localized: "Result")) {
                    if result.doseAmount > 0 {
                        ResultRow(label: "\(result.reagent.product)", value: String(format: "%.2f \(result.unit)", result.doseAmount))
                        Text(String(localized: "Dissolve in ~500 ml RO water before adding to sump."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "Already at or above target.")).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Ca / KH / Mg")
        .onAppear {
            if let tank { volumeStr = String(format: "%.0f", tank.volumeLiters) }
        }
    }

    private func calculate() {
        guard let cur = Double(currentStr),
              let tgt = Double(targetStr),
              let vol = Double(volumeStr),
              let reagent = selectedReagent else { return }

        // For alkalinity: convert dKH → meq/L × HCO3 molar mass
        // 1 dKH = 0.357 meq/L; formula uses (deltaMgL / mMAlk), so deltaMgL = dKH * 0.357 * 61.016 ≈ dKH * 21.78
        let currentMgL = target == .alkalinity ? cur * 21.78 : cur
        let targetMgL  = target == .alkalinity ? tgt * 21.78 : tgt

        result = ChemCalculator.calculate(target: target, currentMgL: currentMgL, targetMgL: targetMgL, volumeLiters: vol, reagent: reagent)
    }
}

// MARK: - Nutrient Calculator View

struct NutrientCalculatorView: View {
    let tank: Tank?

    @State private var nutrientTarget: NutrientTarget = .nitrate
    @State private var currentStr = ""
    @State private var targetStr = ""
    @State private var volumeStr = ""
    @State private var selectedProductIndex = 0
    @State private var resultMl: Double?

    var filteredProducts: [NutrientProduct] {
        nutrientProductLibrary.filter { $0.target == nutrientTarget }
    }
    var selectedProduct: NutrientProduct? {
        filteredProducts.indices.contains(selectedProductIndex) ? filteredProducts[selectedProductIndex] : filteredProducts.first
    }

    var body: some View {
        Form {
            Section(String(localized: "Nutrient")) {
                Picker(String(localized: "Target"), selection: $nutrientTarget) {
                    ForEach(NutrientTarget.allCases, id: \.self) { t in
                        Text(t.localizedName).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: nutrientTarget) { _, _ in selectedProductIndex = 0; resultMl = nil }
            }

            Section(String(localized: "Values (mg/L)")) {
                HStack {
                    Text(String(localized: "Current"))
                    Spacer()
                    TextField(nutrientTarget == .nitrate ? "20" : "0.1", text: $currentStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(String(localized: "Target"))
                    Spacer()
                    TextField(nutrientTarget == .nitrate ? "5" : "0.03", text: $targetStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(String(localized: "Volume (L)"))
                    Spacer()
                    TextField(tank.map { String(format: "%.0f", $0.volumeLiters) } ?? "100", text: $volumeStr).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            }

            Section(String(localized: "Product")) {
                Picker(String(localized: "Product"), selection: $selectedProductIndex) {
                    ForEach(filteredProducts.indices, id: \.self) { i in
                        Text(filteredProducts[i].brand + " " + filteredProducts[i].product).tag(i)
                    }
                }
                .pickerStyle(.menu)
            }

            Section {
                Button(String(localized: "Calculate")) { calculate() }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }

            if let ml = resultMl {
                Section(String(localized: "Result")) {
                    if ml > 0 {
                        ResultRow(label: String(localized: "Dose"), value: String(format: "%.2f ml", ml))
                    } else {
                        Text(String(localized: "Already at or below target.")).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Nutrient Calculator"))
        .onAppear {
            if let tank { volumeStr = String(format: "%.0f", tank.volumeLiters) }
        }
    }

    private func calculate() {
        guard let cur = Double(currentStr),
              let tgt = Double(targetStr),
              let vol = Double(volumeStr),
              let product = selectedProduct else { return }
        resultMl = NutrientCalculator.dose(currentMgL: cur, targetMgL: tgt, volumeLiters: vol, product: product)
    }
}

// MARK: - Shared

struct ResultRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).bold().foregroundStyle(.blue)
        }
    }
}
