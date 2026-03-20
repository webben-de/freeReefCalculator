import SwiftUI
import SwiftData
import PhotosUI

struct AddEditTankView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var tank: Tank?

    @State private var name = ""
    @State private var type: TankType = .saltwater
    @State private var volumeLiters = 100.0
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var coverPhotoData: Data?
    @State private var showingCamera = false

    var isEditing: Bool { tank != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Tank Info")) {
                    TextField(String(localized: "Name"), text: $name)
                    Picker(String(localized: "Type"), selection: $type) {
                        ForEach(TankType.allCases, id: \.self) { t in
                            Text(t.localizedName).tag(t)
                        }
                    }
                    HStack {
                        Text(String(localized: "Volume"))
                        Spacer()
                        TextField("100", value: $volumeLiters, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("L")
                            .foregroundStyle(.secondary)
                    }
                }

                Section(String(localized: "Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }

                Section(String(localized: "Cover Photo")) {
                    if let data = coverPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Button(String(localized: "Remove Photo"), role: .destructive) {
                            coverPhotoData = nil
                            selectedPhoto = nil
                        }
                    } else {
                        if isCameraAvailable {
                            Button(action: { showingCamera = true }) {
                                Label(String(localized: "Take Photo"), systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                            }
                        }
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Label(String(localized: "Choose from Library"), systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .onChange(of: selectedPhoto) { _, newItem in
                            Task {
                                coverPhotoData = try? await newItem?.loadTransferable(type: Data.self)
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "Edit Tank") : String(localized: "New Tank"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let tank {
                    name = tank.name
                    type = tank.type
                    volumeLiters = tank.volumeLiters
                    notes = tank.notes
                    coverPhotoData = tank.coverPhotoData
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPickerView(isPresented: $showingCamera) { data in coverPhotoData = data }
        }
    }

    private func save() {
        if let tank {
            tank.name = name
            tank.type = type
            tank.volumeLiters = volumeLiters
            tank.notes = notes
            tank.coverPhotoData = coverPhotoData
        } else {
            let newTank = Tank(name: name, type: type, volumeLiters: volumeLiters, notes: notes)
            newTank.coverPhotoData = coverPhotoData
            modelContext.insert(newTank)
        }
        dismiss()
    }
}
