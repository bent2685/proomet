import SwiftUI
import SwiftData

struct PromptListView: View {
    let selection: SidebarSelection?
    @Binding var selectedPrompt: PromptItem?
    @Query(sort: \PromptItem.updatedAt, order: .reverse) private var allPrompts: [PromptItem]
    @Environment(\.modelContext) private var modelContext

    private var prompts: [PromptItem] {
        switch selection {
        case .allPrompts, nil:
            return allPrompts
        case .category(let category):
            return allPrompts.filter { $0.category?.persistentModelID == category.persistentModelID }
        case .tag(let tag):
            return allPrompts.filter { $0.tags.contains(tag) }
        case .recent:
            return allPrompts
                .filter { $0.lastUsedAt != nil }
                .sorted { ($0.lastUsedAt ?? .distantPast) > ($1.lastUsedAt ?? .distantPast) }
        }
    }

    private var navigationTitle: String {
        switch selection {
        case .allPrompts, nil: "所有提示词"
        case .category(let cat): cat.name
        case .tag(let tag): tag
        case .recent: "最近使用"
        }
    }

    var body: some View {
        List(selection: $selectedPrompt) {
            ForEach(prompts) { prompt in
                PromptRowView(prompt: prompt)
                    .tag(prompt)
                    .contextMenu {
                        Button("复制内容") { copyPrompt(prompt) }
                        Divider()
                        Button("删除", role: .destructive) { deletePrompt(prompt) }
                    }
            }
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { createPrompt() } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if prompts.isEmpty {
                ContentUnavailableView {
                    Label("暂无提示词", systemImage: "doc.text")
                } description: {
                    Text("点击 + 新建提示词")
                }
            }
        }
    }

    // MARK: - Actions

    private func createPrompt() {
        let item = PromptItem(title: "")
        if case .category(let cat) = selection {
            item.category = cat
        }
        modelContext.insert(item)

        let version = PromptVersion(content: "", title: "", message: "初始版本")
        version.prompt = item
        modelContext.insert(version)
        item.currentVersionId = version.id

        selectedPrompt = item
    }

    private func deletePrompt(_ prompt: PromptItem) {
        if selectedPrompt?.persistentModelID == prompt.persistentModelID {
            selectedPrompt = nil
        }
        modelContext.delete(prompt)
    }

    private func copyPrompt(_ prompt: PromptItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt.content, forType: .string)
        prompt.useCount += 1
        prompt.lastUsedAt = .now
    }
}
