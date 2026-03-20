import SwiftUI
import SwiftData
import PhotosUI

struct AnimalListView: View {
    @Bindable var tank: Tank
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddAnimal = false

    var grouped: [(AnimalCategory, [Animal])] {
        let sorted = tank.animals.sorted { $0.name < $1.name }
        return AnimalCategory.allCases.compactMap { cat in
            let animals = sorted.filter { $0.category == cat }
            return animals.isEmpty ? nil : (cat, animals)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if tank.animals.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No Animals"), systemImage: "fish")
                    } description: {
                        Text("Add the inhabitants of your tank.")
                    } actions: {
                        Button(String(localized: "Add Animal")) { showingAddAnimal = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(grouped, id: \.0) { category, animals in
                            Section {
                                ForEach(animals) { animal in
                                    NavigationLink(destination: AnimalDetailView(animal: animal)) {
                                        AnimalRowView(animal: animal)
                                    }
                                }
                                .onDelete { offsets in
                                    for i in offsets { modelContext.delete(animals[i]) }
                                }
                            } header: {
                                Label(category.localizedName, systemImage: category.systemImage)
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Animals"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddAnimal = true }) {
                        Label(String(localized: "Add"), systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddAnimal) {
            AddEditAnimalView(tank: tank)
        }
    }
}

struct AnimalRowView: View {
    let animal: Animal

    var body: some View {
        HStack(spacing: 12) {
            if let photo = animal.photos.first, let uiImage = UIImage(data: photo.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: animal.category.systemImage)
                            .foregroundStyle(.secondary)
                    }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(animal.name).font(.headline)
                Text(animal.category.localizedName).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct AnimalDetailView: View {
    @Bindable var animal: Animal
    @State private var showingEdit = false
    @State private var showingAddPhoto = false

    var body: some View {
        List {
            if !animal.photos.isEmpty {
                Section(String(localized: "Photos")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(animal.photos) { photo in
                                if let uiImage = UIImage(data: photo.imageData) {
                                    VStack(alignment: .leading) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        if !photo.comment.isEmpty {
                                            Text(photo.comment)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 120)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section(String(localized: "Details")) {
                LabeledContent(String(localized: "Category"), value: animal.category.localizedName)
                LabeledContent(String(localized: "Added"), value: animal.addedAt.formatted(date: .abbreviated, time: .omitted))
            }

            if !animal.notes.isEmpty {
                Section(String(localized: "Notes")) {
                    Text(animal.notes)
                }
            }
        }
        .navigationTitle(animal.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: { showingEdit = true }) {
                        Label(String(localized: "Edit"), systemImage: "pencil")
                    }
                    Button(action: { showingAddPhoto = true }) {
                        Label(String(localized: "Add Photo"), systemImage: "photo.badge.plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditAnimalView(tank: animal.tank, existingAnimal: animal)
        }
        .sheet(isPresented: $showingAddPhoto) {
            AddAnimalPhotoView(animal: animal)
        }
    }
}

struct AddEditAnimalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let tank: Tank?
    var existingAnimal: Animal?

    @State private var name = ""
    @State private var category: AnimalCategory = .fish
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Animal Info")) {
                    TextField(String(localized: "Name"), text: $name)
                    Picker(String(localized: "Category"), selection: $category) {
                        ForEach(AnimalCategory.allCases, id: \.self) { cat in
                            Label(cat.localizedName, systemImage: cat.systemImage).tag(cat)
                        }
                    }
                }
                Section(String(localized: "Notes")) {
                    TextEditor(text: $notes).frame(minHeight: 80)
                }
            }
            .navigationTitle(existingAnimal != nil ? String(localized: "Edit Animal") : String(localized: "New Animal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(String(localized: "Cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let a = existingAnimal {
                    name = a.name; category = a.category; notes = a.notes
                }
            }
        }
    }

    private func save() {
        if let animal = existingAnimal {
            animal.name = name; animal.category = category; animal.notes = notes
        } else if let tank {
            let animal = Animal(name: name, category: category, notes: notes)
            animal.tank = tank
            modelContext.insert(animal)
        }
        dismiss()
    }
}

struct AddAnimalPhotoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let animal: Animal

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var comment = ""
    @State private var showingCamera = false

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Photo")) {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Button(String(localized: "Remove"), role: .destructive) { imageData = nil }
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
                        .onChange(of: selectedPhoto) { _, new in
                            Task { imageData = try? await new?.loadTransferable(type: Data.self) }
                        }
                    }
                }
                Section(String(localized: "Comment")) {
                    TextField(String(localized: "Optional comment…"), text: $comment)
                }
            }
            .navigationTitle(String(localized: "Add Photo"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(String(localized: "Cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        guard let data = imageData else { return }
                        let photo = AnimalPhoto(imageData: data, comment: comment)
                        photo.animal = animal
                        modelContext.insert(photo)
                        dismiss()
                    }
                    .disabled(imageData == nil)
                }
            }
        }
        .fullScreenCover(isPresented: $showingCamera) {
            CameraPickerView(isPresented: $showingCamera) { data in imageData = data }
        }
    }
}
