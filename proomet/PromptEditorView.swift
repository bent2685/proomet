import SwiftUI
import SwiftData

struct PromptEditorView: View {
    @Bindable var prompt: PromptItem
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PromptCategory.sortOrder) private var categories: [PromptCategory]
    @Query private var allPrompts: [PromptItem]

    @State private var showCopiedToast = false
    @State private var showTagEditor = false

    private var allUsedTags: [String] {
        Array(Set(allPrompts.flatMap(\.tags))).sorted()
    }

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

                // Tags button → popover
                Button {
                    showTagEditor.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "tag")
                            .foregroundStyle(.secondary)
                        if prompt.tags.isEmpty {
                            Text("添加标签")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(prompt.tags.prefix(3), id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.quaternary)
                                    .clipShape(Capsule())
                            }
                            if prompt.tags.count > 3 {
                                Text("+\(prompt.tags.count - 3)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showTagEditor) {
                    TagEditorView(tags: $prompt.tags, allTags: allUsedTags)
                }

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
