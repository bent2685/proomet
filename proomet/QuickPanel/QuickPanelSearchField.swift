import SwiftUI

struct QuickPanelSearchField: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .font(.system(size: 16))
            TextField("搜索 Prompt...", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 16))
                .focused($isFocused)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
