import SwiftUI
import SwiftData
import Charts

struct ParameterHistoryView: View {
    @Bindable var tank: Tank
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddParameter = false
    @State private var viewMode: ViewMode = .chart
    @State private var selectedMetric: ParameterMetric = .temperature

    var sortedParams: [WaterParameter] {
        tank.parameters.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker(String(localized: "View"), selection: $viewMode) {
                    Label(String(localized: "Chart"), systemImage: "chart.line.uptrend.xyaxis").tag(ViewMode.chart)
                    Label(String(localized: "Table"), systemImage: "tablecells").tag(ViewMode.table)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if viewMode == .chart {
                    ParameterChartView(parameters: sortedParams, metric: $selectedMetric)
                } else {
                    ParameterTableView(parameters: sortedParams, modelContext: modelContext)
                }
            }
            .navigationTitle(String(localized: "Parameters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddParameter = true }) {
                        Label(String(localized: "Add"), systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddParameter) {
            AddParameterView(tank: tank)
        }
    }

    enum ViewMode { case chart, table }
}

struct ParameterChartView: View {
    let parameters: [WaterParameter]
    @Binding var metric: ParameterMetric

    var chartData: [(date: Date, value: Double)] {
        parameters.compactMap { p in
            guard let val = metric.value(from: p) else { return nil }
            return (date: p.timestamp, value: val)
        }
        .sorted { $0.date < $1.date }
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ParameterMetric.allCases, id: \.self) { m in
                        Button(m.label) { metric = m }
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(metric == m ? m.color : Color(.systemGray5))
                            .foregroundStyle(metric == m ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 6)

            if chartData.isEmpty {
                ContentUnavailableView(String(localized: "No Data"), systemImage: "chart.line.downtrend.xyaxis")
                    .frame(maxHeight: .infinity)
            } else {
                Chart(chartData, id: \.date) { item in
                    LineMark(x: .value("Date", item.date), y: .value(metric.label, item.value))
                        .foregroundStyle(metric.color)
                    PointMark(x: .value("Date", item.date), y: .value(metric.label, item.value))
                        .foregroundStyle(metric.color)
                }
                .chartXAxis { AxisMarks(values: .automatic) }
                .chartYAxisLabel(metric.unit)
                .padding()
            }
        }
    }
}

struct ParameterTableView: View {
    let parameters: [WaterParameter]
    let modelContext: ModelContext

    var body: some View {
        List {
            ForEach(parameters) { param in
                NavigationLink(destination: ParameterDetailView(parameter: param)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(param.timestamp, style: .date)
                            .font(.subheadline.bold())
                        Text(param.timestamp, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ParameterSummaryRow(parameter: param)
                    }
                    .padding(.vertical, 2)
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    modelContext.delete(parameters[index])
                }
            }
        }
    }
}

struct ParameterSummaryRow: View {
    let parameter: WaterParameter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let v = parameter.temperatureCelsius { MiniChip(label: "T", value: String(format: "%.1f°", v)) }
                if let v = parameter.specificGravity    { MiniChip(label: "SG", value: String(format: "%.3f", v)) }
                if let v = parameter.pH                 { MiniChip(label: "pH", value: String(format: "%.1f", v)) }
                if let v = parameter.calcium            { MiniChip(label: "Ca", value: "\(Int(v))") }
                if let v = parameter.alkalinityDKH      { MiniChip(label: "KH", value: String(format: "%.1f", v)) }
                if let v = parameter.magnesium          { MiniChip(label: "Mg", value: "\(Int(v))") }
                if let v = parameter.nitrate            { MiniChip(label: "NO₃", value: String(format: "%.1f", v)) }
                if let v = parameter.phosphate          { MiniChip(label: "PO₄", value: String(format: "%.3f", v)) }
            }
        }
    }
}

struct MiniChip: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 2) {
            Text(label).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption2.bold())
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

enum ParameterMetric: String, CaseIterable {
    case temperature, specificGravity, pH, calcium, alkalinity, magnesium, nitrate, phosphate

    var label: String {
        switch self {
        case .temperature:   return "Temp"
        case .specificGravity: return "S.G."
        case .pH:            return "pH"
        case .calcium:       return "Ca"
        case .alkalinity:    return "KH"
        case .magnesium:     return "Mg"
        case .nitrate:       return "NO₃"
        case .phosphate:     return "PO₄"
        }
    }

    var unit: String {
        switch self {
        case .temperature:   return "°C"
        case .specificGravity: return ""
        case .pH:            return ""
        case .calcium:       return "mg/L"
        case .alkalinity:    return "dKH"
        case .magnesium:     return "mg/L"
        case .nitrate:       return "mg/L"
        case .phosphate:     return "mg/L"
        }
    }

    var color: Color {
        switch self {
        case .temperature:   return .orange
        case .specificGravity: return .blue
        case .pH:            return .purple
        case .calcium:       return .teal
        case .alkalinity:    return .indigo
        case .magnesium:     return .cyan
        case .nitrate:       return .red
        case .phosphate:     return .pink
        }
    }

    func value(from p: WaterParameter) -> Double? {
        switch self {
        case .temperature:   return p.temperatureCelsius
        case .specificGravity: return p.specificGravity
        case .pH:            return p.pH
        case .calcium:       return p.calcium
        case .alkalinity:    return p.alkalinityDKH
        case .magnesium:     return p.magnesium
        case .nitrate:       return p.nitrate
        case .phosphate:     return p.phosphate
        }
    }
}
