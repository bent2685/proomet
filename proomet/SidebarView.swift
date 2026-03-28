import SwiftUI
import SwiftData

struct SidebarView: View {
    @Binding var selection: SidebarSelection?
    @Query(sort: \PromptCategory.sortOrder) private var categories: [PromptCategory]
    @Query(sort: \PromptItem.updatedAt, order: .reverse) private var allPrompts: [PromptItem]
    @Environment(\.modelContext) private var modelContext

    @State private var editingCategoryId: UUID? = nil
    @State private var editingName = ""

    private var usedTags: [String] {
        Array(Set(allPrompts.flatMap(\.tags))).sorted()
    }

    var body: some View {
        List(selection: $selection) {
            // Section 1: All prompts
            Section {
                Label("所有提示词", systemImage: "tray.full")
                    .tag(SidebarSelection.allPrompts)
            }

            // Section 2: Categories
            Section {
                ForEach(categories) { category in
                    CategoryRow(
                        category: category,
                        editingCategoryId: $editingCategoryId,
                        editingName: $editingName,
                        onCommitRename: commitRename,
                        onCancelRename: cancelRename,
                        onDelete: { deleteCategory(category) }
                    )
                }
            } header: {
                HStack {
                    Text("分类")
                    Spacer()
                }
                .contentShape(Rectangle())
                .contextMenu {
                    Button("新增分类") {
                        addAndStartRename()
                    }
                }
            }

            // Section 3: Tags
            if !usedTags.isEmpty {
                Section("标签") {
                    ForEach(usedTags, id: \.self) { tag in
                        Label(tag, systemImage: "tag")
                            .tag(SidebarSelection.tag(tag))
                    }
                }
            }
        }
        .navigationTitle("Proomet")
        .onChange(of: categories) { _, newCategories in
            if case .category(let cat) = selection,
               !newCategories.contains(where: { $0.persistentModelID == cat.persistentModelID }) {
                selection = .allPrompts
            }
        }
    }

    // MARK: - Actions

    private func addAndStartRename() {
        let maxOrder = categories.map(\.sortOrder).max() ?? -1
        let base = "未命名分类"
        var name = base
        var n = 2
        while categories.contains(where: { $0.name == name }) {
            name = "\(base)\(n)"
            n += 1
        }
        let category = PromptCategory(name: name, sortOrder: maxOrder + 1)
        modelContext.insert(category)
        editingCategoryId = category.id
        editingName = category.name
    }

    private func commitRename() {
        guard let id = editingCategoryId,
              let category = categories.first(where: { $0.id == id }) else {
            editingCategoryId = nil
            return
        }
        let trimmed = editingName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            category.name = trimmed
        }
        editingCategoryId = nil
        editingName = ""
    }

    private func cancelRename() {
        editingCategoryId = nil
        editingName = ""
    }

    private func deleteCategory(_ category: PromptCategory) {
        modelContext.delete(category)
    }
}
