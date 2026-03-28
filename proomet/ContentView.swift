import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var sidebarSelection: SidebarSelection? = .allPrompts
    @State private var selectedPrompt: PromptItem?

    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $sidebarSelection)
        } content: {
            PromptListView(selection: sidebarSelection, selectedPrompt: $selectedPrompt)
        } detail: {
            if let selectedPrompt {
                PromptEditorView(prompt: selectedPrompt)
                    .id(selectedPrompt.persistentModelID)
            } else {
                ContentUnavailableView {
                    Label("选择一个提示词", systemImage: "doc.text")
                } description: {
                    Text("从列表中选择提示词，或点击 + 新建")
                }
            }
        }
        .onChange(of: sidebarSelection) { _, _ in
            selectedPrompt = nil
        }
    }
}
