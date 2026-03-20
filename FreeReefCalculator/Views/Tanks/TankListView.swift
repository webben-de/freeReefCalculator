import SwiftUI
import SwiftData

struct TankListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tank.createdAt) private var tanks: [Tank]
    @State private var showingAddTank = false

    var body: some View {
        NavigationStack {
            Group {
                if tanks.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No Tanks"), systemImage: "drop.fill")
                    } description: {
                        Text("Add your first aquarium to get started.")
                    } actions: {
                        Button(String(localized: "Add Tank")) { showingAddTank = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(tanks) { tank in
                            NavigationLink(destination: TankDetailView(tank: tank)) {
                                TankRowView(tank: tank)
                            }
                        }
                        .onDelete(perform: deleteTanks)
                    }
                }
            }
            .navigationTitle(String(localized: "My Tanks"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddTank = true }) {
                        Label(String(localized: "Add Tank"), systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTank) {
                AddEditTankView()
            }
        }
    }

    private func deleteTanks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tanks[index])
        }
    }
}

struct TankRowView: View {
    let tank: Tank

    var body: some View {
        HStack(spacing: 12) {
            if let data = tank.coverPhotoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(tank.type == .saltwater ? Color.blue.opacity(0.15) : Color.green.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(tank.type == .saltwater ? .blue : .green)
                            .font(.title2)
                    }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(tank.name)
                    .font(.headline)
                HStack {
                    Text(tank.type.localizedName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.0f L", tank.volumeLiters))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let latest = tank.parameters.max(by: { $0.timestamp < $1.timestamp }) {
                    Text(latest.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
