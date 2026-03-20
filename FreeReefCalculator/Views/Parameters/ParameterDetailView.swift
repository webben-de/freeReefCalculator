import SwiftUI

struct ParameterDetailView: View {
    @Bindable var parameter: WaterParameter
    @State private var showingEdit = false

    var body: some View {
        List {
            Section(String(localized: "Date")) {
                Text(parameter.timestamp.formatted(date: .long, time: .shortened))
            }
            if !parameter.notes.isEmpty {
                Section(String(localized: "Notes")) {
                    Text(parameter.notes)
                }
            }
            paramSection(String(localized: "Temperature"), items: [
                ("Temp", parameter.temperatureCelsius.map { String(format: "%.1f °C", $0) })
            ])
            paramSection(String(localized: "Salinity"), items: [
                ("S.G.", parameter.specificGravity.map { String(format: "%.4f", $0) }),
                ("ppt", parameter.salinityPpt.map { String(format: "%.1f", $0) })
            ])
            paramSection("pH", items: [
                ("pH", parameter.pH.map { String(format: "%.2f", $0) })
            ])
            paramSection(String(localized: "Major Elements"), items: [
                ("Ca", parameter.calcium.map { "\(Int($0)) mg/L" }),
                ("KH", parameter.alkalinityDKH.map { String(format: "%.1f dKH", $0) }),
                ("Mg", parameter.magnesium.map { "\(Int($0)) mg/L" })
            ])
            paramSection(String(localized: "Nutrients"), items: [
                ("NO₃", parameter.nitrate.map { String(format: "%.2f mg/L", $0) }),
                ("NO₂", parameter.nitrite.map { String(format: "%.3f mg/L", $0) }),
                ("PO₄", parameter.phosphate.map { String(format: "%.3f mg/L", $0) }),
                ("NH₄", parameter.ammonia.map { String(format: "%.2f mg/L", $0) })
            ])
            paramSection(String(localized: "Trace Elements"), items: [
                ("K", parameter.potassium.map { "\(Int($0)) mg/L" }),
                ("Sr", parameter.strontium.map { String(format: "%.2f mg/L", $0) }),
                ("I", parameter.iodine.map { String(format: "%.1f µg/L", $0) }),
                ("O₂", parameter.oxygen.map { String(format: "%.1f mg/L", $0) })
            ])
        }
        .navigationTitle(parameter.timestamp.formatted(.dateTime.day().month().year()))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingEdit = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            if let tank = parameter.tank {
                AddParameterView(tank: tank, existing: parameter)
            }
        }
    }

    @ViewBuilder
    private func paramSection(_ title: String, items: [(String, String?)]) -> some View {
        let filtered = items.compactMap { label, val -> (String, String)? in
            guard let val else { return nil }
            return (label, val)
        }
        if !filtered.isEmpty {
            Section(title) {
                ForEach(filtered, id: \.0) { label, value in
                    HStack {
                        Text(label)
                        Spacer()
                        Text(value).foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
