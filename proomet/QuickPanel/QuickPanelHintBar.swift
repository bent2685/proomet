import SwiftUI

struct QuickPanelHintBar: View {
    var body: some View {
        HStack(spacing: 16) {
            hintItem("↑↓", "切换")
            hintItem("⏎", "粘贴")
            hintItem("⎋", "关闭")
            Spacer()
            hintItem("⌘1", "全部")
            hintItem("⌘2", "分类")
            hintItem("⌘3", "标签")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func hintItem(_ key: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Color.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 3))
            Text(label)
                .font(.system(size: 11))
        }
        .foregroundStyle(.secondary)
    }
}
