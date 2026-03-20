import SwiftUI

struct FAQEntry: Identifiable, Codable {
    let id: String
    let category: String
    let question: String
    let answer: String
}

struct FAQView: View {
    @State private var entries: [FAQEntry] = []
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil

    var categories: [String] {
        Array(Set(entries.map(\.category))).sorted()
    }

    var filtered: [FAQEntry] {
        entries.filter { entry in
            let matchesCategory = selectedCategory == nil || entry.category == selectedCategory
            let matchesSearch = searchText.isEmpty
                || entry.question.localizedCaseInsensitiveContains(searchText)
                || entry.answer.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var groupedFiltered: [(String, [FAQEntry])] {
        Dictionary(grouping: filtered, by: \.category)
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                if !categories.isEmpty {
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                CategoryChip(label: String(localized: "All"), isSelected: selectedCategory == nil) {
                                    selectedCategory = nil
                                }
                                ForEach(categories, id: \.self) { cat in
                                    CategoryChip(label: cat, isSelected: selectedCategory == cat) {
                                        selectedCategory = cat == selectedCategory ? nil : cat
                                    }
                                }
                            }
                        }
                    }
                    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                }

                ForEach(groupedFiltered, id: \.0) { category, faqs in
                    Section(category) {
                        ForEach(faqs) { entry in
                            NavigationLink(destination: FAQDetailView(entry: entry)) {
                                Text(entry.question)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "Search FAQ"))
            .navigationTitle(String(localized: "Reference"))
        }
        .onAppear { loadFAQ() }
    }

    private func loadFAQ() {
        guard let url = Bundle.main.url(forResource: "faq", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return }
        entries = (try? JSONDecoder().decode([FAQEntry].self, from: data)) ?? []
    }
}

struct FAQDetailView: View {
    let entry: FAQEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.question)
                    .font(.title2.bold())
                Divider()
                Text(entry.answer)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
        .navigationTitle(entry.category)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CategoryChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}
