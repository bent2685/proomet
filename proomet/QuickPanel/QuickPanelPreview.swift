import SwiftUI

struct QuickPanelPreview: View {
    let content: String?

    var body: some View {
        if let content, !content.isEmpty {
            ScrollView {
                Text(content)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .textSelection(.enabled)
            }
        } else {
            Text("无内容")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
