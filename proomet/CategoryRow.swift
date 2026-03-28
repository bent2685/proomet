import SwiftUI

struct CategoryRow: View {
    let category: PromptCategory
    @Binding var editingCategoryId: UUID?
    @Binding var editingName: String
    let onCommitRename: () -> Void
    let onCancelRename: () -> Void
    let onDelete: () -> Void

    @FocusState private var isFocused: Bool

    var isEditing: Bool { editingCategoryId == category.id }

    var body: some View {
        Label {
            if isEditing {
                TextField("", text: $editingName)
                    .focused($isFocused)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }
                    .onSubmit { onCommitRename() }
                    .onKeyPress(.escape) {
                        onCancelRename()
                        return .handled
                    }
            } else {
                Text(category.name)
            }
        } icon: {
            Image(systemName: "folder")
        }
        .tag(SidebarSelection.category(category))
        .contextMenu {
            Button("重命名") {
                editingCategoryId = category.id
                editingName = category.name
            }
            if !category.isDefault {
                Divider()
                Button("删除", role: .destructive, action: onDelete)
            }
        }
    }
}
