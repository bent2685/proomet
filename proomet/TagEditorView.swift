import SwiftUI

struct TagEditorView: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    @State private var isAddingTag = false
    @FocusState private var isTagFieldFocused: Bool

    var body: some View {
        FlowLayout(spacing: 4) {
            ForEach(tags, id: \.self) { tag in
                TagChip(name: tag) {
                    withAnimation { tags.removeAll { $0 == tag } }
                }
            }

            if isAddingTag {
                TextField("标签", text: $newTag)
                    .textFieldStyle(.plain)
                    .frame(width: 80)
                    .focused($isTagFieldFocused)
                    .onSubmit { commitTag() }
                    .onKeyPress(.escape) {
                        cancelAddTag()
                        return .handled
                    }
                    .onAppear { isTagFieldFocused = true }
            } else {
                Button {
                    isAddingTag = true
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func commitTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            withAnimation { tags.append(trimmed) }
        }
        newTag = ""
        isAddingTag = false
    }

    private func cancelAddTag() {
        newTag = ""
        isAddingTag = false
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 2) {
            Text(name)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.quaternary)
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 4

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews)
        -> (size: CGSize, positions: [CGPoint])
    {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
