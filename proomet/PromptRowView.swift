import SwiftUI

struct PromptRowView: View {
    let prompt: PromptItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(prompt.title.isEmpty ? "未命名提示词" : prompt.title)
                .font(.headline)
                .lineLimit(1)

            if !prompt.content.isEmpty {
                Text(prompt.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !prompt.tags.isEmpty {
                HStack(spacing: 4) {
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
        .padding(.vertical, 2)
    }
}
