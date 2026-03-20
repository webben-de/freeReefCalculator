import SwiftUI
import SwiftData

struct AddParameterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let tank: Tank
    var existing: WaterParameter? = nil

    // Temperature
    @State private var temperatureStr = ""
    // Salinity
    @State private var specificGravityStr = ""
    @State private var salinityPptStr = ""
    // pH
    @State private var pHStr = ""
    // Calcium
    @State private var calciumStr = ""
    // Alkalinity
    @State private var alkalinityDKHStr = ""
    // Magnesium
    @State private var magnesiumStr = ""
    // Nutrients
    @State private var nitrateStr = ""
    @State private var nitriteStr = ""
    @State private var phosphateStr = ""
    @State private var ammoniaStr = ""
    // Extras
    @State private var potassiumStr = ""
    @State private var strontiumStr = ""
    @State private var iodineStr = ""
    @State private var oxygenStr = ""

    @State private var notes = ""
    @State private var timestamp = Date()

    private var isEditing: Bool { existing != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Date & Notes")) {
                    DatePicker(String(localized: "Date"), selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
                    TextField(String(localized: "Notes"), text: $notes)
                }
                Section(String(localized: "Temperature")) {
                    paramField(String(localized: "Temperature (°C)"), text: $temperatureStr)
                }
                Section(String(localized: "Salinity")) {
                    paramField("S.G. (e.g. 1.025)", text: $specificGravityStr)
                    paramField("Salinity (ppt)", text: $salinityPptStr)
                }
                Section("pH") {
                    paramField("pH (e.g. 8.2)", text: $pHStr)
                }
                Section(String(localized: "Major Elements")) {
                    paramField("Calcium (mg/L)", text: $calciumStr)
                    paramField("Alkalinity (dKH)", text: $alkalinityDKHStr)
                    paramField("Magnesium (mg/L)", text: $magnesiumStr)
                }
                Section(String(localized: "Nutrients")) {
                    paramField("Nitrate NO₃ (mg/L)", text: $nitrateStr)
                    paramField("Nitrite NO₂ (mg/L)", text: $nitriteStr)
                    paramField("Phosphate PO₄ (mg/L)", text: $phosphateStr)
                    paramField("Ammonia NH₄ (mg/L)", text: $ammoniaStr)
                }
                Section(String(localized: "Trace Elements")) {
                    paramField("Potassium (mg/L)", text: $potassiumStr)
                    paramField("Strontium (mg/L)", text: $strontiumStr)
                    paramField("Iodine (µg/L)", text: $iodineStr)
                    paramField("Oxygen (mg/L)", text: $oxygenStr)
                }
            }
            .navigationTitle(isEditing ? String(localized: "Edit Parameters") : String(localized: "Log Parameters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(String(localized: "Cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button(String(localized: "Save")) { save() } }
            }
            .onAppear { prefill() }
        }
    }

    @ViewBuilder
    private func paramField(_ placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Text(placeholder).foregroundStyle(.primary)
            Spacer()
            TextField("—", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.secondary)
                .frame(width: 100)
        }
    }

    private func prefill() {
        guard let p = existing else { return }
        timestamp          = p.timestamp
        notes              = p.notes
        temperatureStr     = p.temperatureCelsius.map { format($0) } ?? ""
        specificGravityStr = p.specificGravity.map    { format($0, decimals: 4) } ?? ""
        salinityPptStr     = p.salinityPpt.map        { format($0) } ?? ""
        pHStr              = p.pH.map                 { format($0) } ?? ""
        calciumStr         = p.calcium.map            { format($0) } ?? ""
        alkalinityDKHStr   = p.alkalinityDKH.map      { format($0) } ?? ""
        magnesiumStr       = p.magnesium.map          { format($0) } ?? ""
        nitrateStr         = p.nitrate.map            { format($0) } ?? ""
        nitriteStr         = p.nitrite.map            { format($0) } ?? ""
        phosphateStr       = p.phosphate.map          { format($0) } ?? ""
        ammoniaStr         = p.ammonia.map            { format($0) } ?? ""
        potassiumStr       = p.potassium.map          { format($0) } ?? ""
        strontiumStr       = p.strontium.map          { format($0) } ?? ""
        iodineStr          = p.iodine.map             { format($0) } ?? ""
        oxygenStr          = p.oxygen.map             { format($0) } ?? ""
    }

    private func format(_ value: Double, decimals: Int = 2) -> String {
        String(format: "%.\(decimals)g", value)
    }

    private func save() {
        let param = existing ?? WaterParameter(timestamp: timestamp, notes: notes)
        param.timestamp        = timestamp
        param.notes            = notes
        param.temperatureCelsius = Double(temperatureStr)
        param.specificGravity    = Double(specificGravityStr)
        param.salinityPpt        = Double(salinityPptStr)
        param.pH                 = Double(pHStr)
        param.calcium            = Double(calciumStr)
        param.alkalinityDKH      = Double(alkalinityDKHStr)
        param.magnesium          = Double(magnesiumStr)
        param.nitrate            = Double(nitrateStr)
        param.nitrite            = Double(nitriteStr)
        param.phosphate          = Double(phosphateStr)
        param.ammonia            = Double(ammoniaStr)
        param.potassium          = Double(potassiumStr)
        param.strontium          = Double(strontiumStr)
        param.iodine             = Double(iodineStr)
        param.oxygen             = Double(oxygenStr)
        if existing == nil {
            param.tank = tank
            modelContext.insert(param)
        }
        dismiss()
    }
}
