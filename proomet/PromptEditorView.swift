import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Bindable var prompt: PromptItem
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PromptCategory.sortOrder) private var categories: [PromptCategory]

    @State private var showCopiedToast = false

    var body: some View {
        VStack(spacing: 0) {
            // Title
            TextField("提示词标题", text: $prompt.title)
                .font(.title2.weight(.medium))
                .textFieldStyle(.plain)
                .padding(.horizontal)
                .padding(.vertical, 12)

            Divider()

            // Metadata bar
            HStack(spacing: 12) {
                // Category picker
                Picker(selection: $prompt.category) {
                    Text("无分类").tag(nil as PromptCategory?)
                    ForEach(categories) { cat in
                        Text(cat.name).tag(cat as PromptCategory?)
                    }
                } label: {
                    Label("分类", systemImage: "folder")
                }
                .fixedSize()

                Divider()
                    .frame(height: 16)

                // Tags
                TagEditorView(tags: $prompt.tags)

                Spacer()

                // Stats
                if prompt.useCount > 0 {
                    Label("\(prompt.useCount)", systemImage: "doc.on.doc")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Content editor
            MarkdownEditorView(text: $prompt.content)
        }
        .onChange(of: prompt.title) { _, _ in
            prompt.updatedAt = .now
        }
        .onChange(of: prompt.content) { _, _ in
            prompt.updatedAt = .now
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    copyToClipboard()
                } label: {
                    Label(showCopiedToast ? "已复制" : "复制",
                          systemImage: showCopiedToast ? "checkmark" : "doc.on.doc")
                }
                .disabled(prompt.content.isEmpty)
            }
        }
        .navigationTitle(prompt.title.isEmpty ? "新提示词" : prompt.title)
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt.content, forType: .string)
        prompt.useCount += 1
        prompt.lastUsedAt = .now

        showCopiedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showCopiedToast = false
        }
    }
}
