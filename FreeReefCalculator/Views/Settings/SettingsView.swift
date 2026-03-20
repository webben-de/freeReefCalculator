import SwiftUI

struct SettingsView: View {
    @AppStorage("volumeUnit") private var volumeUnit: VolumeUnit = .liters
    @AppStorage("tempUnit") private var tempUnit: TempUnit = .celsius
    @AppStorage("salinityDisplay") private var salinityDisplay: SalinityDisplay = .specificGravity
    @AppStorage("alkDisplay") private var alkDisplay: AlkDisplay = .dkh

    // Calibration offsets
    @AppStorage("offsetTemp") private var offsetTemp = 0.0
    @AppStorage("offsetPH") private var offsetPH = 0.0
    @AppStorage("offsetSG") private var offsetSG = 0.0

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Units")) {
                    Picker(String(localized: "Volume"), selection: $volumeUnit) {
                        ForEach(VolumeUnit.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    Picker(String(localized: "Temperature"), selection: $tempUnit) {
                        ForEach(TempUnit.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    Picker(String(localized: "Salinity Display"), selection: $salinityDisplay) {
                        ForEach(SalinityDisplay.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                    Picker(String(localized: "Alkalinity Display"), selection: $alkDisplay) {
                        ForEach(AlkDisplay.allCases, id: \.self) { Text($0.label).tag($0) }
                    }
                }

                Section {
                    Text(String(localized: "Adjust probe offsets to compensate for measurement device calibration."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(String(localized: "Probe Calibration Offsets"))
                }

                Section {
                    offsetStepper(String(localized: "Temperature Offset (°C)"), value: $offsetTemp, step: 0.1, range: -5...5)
                    offsetStepper("pH Offset", value: $offsetPH, step: 0.01, range: -1...1)
                    offsetStepper("S.G. Offset", value: $offsetSG, step: 0.001, range: -0.01...0.01)
                }

                Section(String(localized: "About")) {
                    HStack {
                        Text(String(localized: "Version"))
                        Spacer()
                        Text(appVersion).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(String(localized: "App"))
                        Spacer()
                        Text("FreeReef").foregroundStyle(.secondary)
                    }
                    Text(String(localized: "A free, open-source reef aquarium management app."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(String(localized: "Settings"))
        }
    }

    @ViewBuilder
    private func offsetStepper(_ label: String, value: Binding<Double>, step: Double, range: ClosedRange<Double>) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: step < 0.1 ? "%+.3f" : step < 1 ? "%+.2f" : "%+.1f", value.wrappedValue))
                .foregroundStyle(.secondary)
                .frame(width: 70)
            Stepper("", value: value, in: range, step: step)
                .labelsHidden()
        }
    }
}

// MARK: - Unit Enums

enum VolumeUnit: String, CaseIterable {
    case liters, gallonsUS
    var label: String { self == .liters ? "Liters (L)" : "US Gallons" }
    func convert(_ liters: Double) -> Double { self == .liters ? liters : liters * 0.264172 }
}

enum TempUnit: String, CaseIterable {
    case celsius, fahrenheit
    var label: String { self == .celsius ? "Celsius (°C)" : "Fahrenheit (°F)" }
    func convert(_ celsius: Double) -> Double { self == .celsius ? celsius : celsius * 9/5 + 32 }
}

enum SalinityDisplay: String, CaseIterable {
    case specificGravity, ppt
    var label: String { self == .specificGravity ? "Specific Gravity (S.G.)" : "Parts Per Thousand (ppt)" }
}

enum AlkDisplay: String, CaseIterable {
    case dkh, meqL
    var label: String { self == .dkh ? "dKH (°dH)" : "meq/L" }
}
