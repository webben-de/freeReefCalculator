import SwiftUI
import SwiftData

struct TankDashboardView: View {
    @Bindable var tank: Tank
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddParameter = false
    @State private var showingEditTank = false
    @State private var showingCalculators = false

    var latestParam: WaterParameter? {
        tank.parameters.max(by: { $0.timestamp < $1.timestamp })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Cover photo / header
                    TankHeaderCard(tank: tank)

                    // Latest parameters summary
                    if let param = latestParam {
                        LatestParameterCard(parameter: param)
                    } else {
                        ContentUnavailableView {
                            Label(String(localized: "No Parameters"), systemImage: "drop")
                        } description: {
                            Text("Log your first water test to see values here.")
                        } actions: {
                            Button(String(localized: "Log Parameters")) { showingAddParameter = true }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }

                    // Quick actions
                    QuickActionsRow(
                        onLogParams: { showingAddParameter = true },
                        onCalculators: { showingCalculators = true }
                    )

                    // Upcoming reminders
                    UpcomingRemindersCard(tank: tank)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Dashboard"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingEditTank = true }) {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddParameter) {
            AddParameterView(tank: tank)
        }
        .sheet(isPresented: $showingEditTank) {
            AddEditTankView(tank: tank)
        }
        .sheet(isPresented: $showingCalculators) {
            CalculatorsView(tank: tank)
        }
    }
}

struct TankHeaderCard: View {
    let tank: Tank

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = tank.coverPhotoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(tank.type == .saltwater
                          ? LinearGradient(colors: [.blue.opacity(0.6), .cyan.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [.green.opacity(0.6), .mint.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(maxWidth: .infinity)
                    .frame(height: 160)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.4))
                    }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tank.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("\(tank.type.localizedName) · \(String(format: "%.0f L", tank.volumeLiters))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(12)
            .background(.ultraThinMaterial.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(10)
        }
    }
}

struct LatestParameterCard: View {
    let parameter: WaterParameter

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(String(localized: "Latest Reading"))
                    .font(.headline)
                Spacer()
                Text(parameter.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Divider()
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let v = parameter.temperatureCelsius { ParamChip(label: "Temp", value: String(format: "%.1f°C", v), color: .orange) }
                if let v = parameter.specificGravity     { ParamChip(label: "S.G.", value: String(format: "%.3f", v), color: .blue) }
                if let v = parameter.pH                  { ParamChip(label: "pH", value: String(format: "%.1f", v), color: .purple) }
                if let v = parameter.calcium             { ParamChip(label: "Ca", value: "\(Int(v)) mg/L", color: .teal) }
                if let v = parameter.alkalinityDKH       { ParamChip(label: "KH", value: String(format: "%.1f dKH", v), color: .indigo) }
                if let v = parameter.magnesium           { ParamChip(label: "Mg", value: "\(Int(v)) mg/L", color: .cyan) }
                if let v = parameter.nitrate             { ParamChip(label: "NO₃", value: String(format: "%.2f", v), color: .red) }
                if let v = parameter.phosphate           { ParamChip(label: "PO₄", value: String(format: "%.3f", v), color: .pink) }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ParamChip: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct QuickActionsRow: View {
    let onLogParams: () -> Void
    let onCalculators: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onLogParams) {
                Label(String(localized: "Log Test"), systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(action: onCalculators) {
                Label(String(localized: "Calculators"), systemImage: "function")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct UpcomingRemindersCard: View {
    let tank: Tank

    var upcoming: [Reminder] {
        tank.reminders
            .filter { $0.isActive }
            .sorted { $0.nextDue < $1.nextDue }
            .prefix(3)
            .map { $0 }
    }

    var body: some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "Upcoming Reminders"))
                    .font(.headline)
                Divider()
                ForEach(upcoming) { reminder in
                    HStack {
                        Image(systemName: reminder.isOverdue ? "exclamationmark.circle.fill" : "clock.fill")
                            .foregroundStyle(reminder.isOverdue ? .red : .orange)
                        Text(reminder.title)
                            .font(.subheadline)
                        Spacer()
                        Text(reminder.nextDue, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
