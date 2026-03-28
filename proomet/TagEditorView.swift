import SwiftUI

struct TagEditorView: View {
    @Binding var tags: [String]
    let allTags: [String]

    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    private var suggestions: [String] {
        allTags.filter { !tags.contains($0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("为提示词添加标签")
                .font(.headline)
                .frame(maxWidth: .infinity)

            // Input area: chips + inline text field
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    InputTagChip(name: tag) {
                        withAnimation { tags.removeAll { $0 == tag } }
                    }
                }

                TextField("输入标签…", text: $inputText)
                    .textFieldStyle(.plain)
                    .focused($isInputFocused)
                    .frame(minWidth: 60, maxWidth: .infinity)
                    .onSubmit { commitTag() }
                    .onKeyPress(.delete) {
                        if inputText.isEmpty, !tags.isEmpty {
                            withAnimation { tags.removeLast() }
                            return .handled
                        }
                        return .ignored
                    }
            }
            .padding(8)
            .background(.background.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.quaternary)
            )

            // Suggestions
            Text("建议")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if suggestions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "wand.and.stars")
                        .font(.title)
                        .foregroundStyle(.quaternary)
                    Text("添加更多标签后，建议将显示在此处")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                FlowLayout(spacing: 6) {
                    ForEach(suggestions, id: \.self) { tag in
                        Button {
                            withAnimation { tags.append(tag) }
                        } label: {
                            Text(tag)
                                .font(.callout)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.quaternary)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .frame(width: 280, alignment: .leading)
        .onAppear { isInputFocused = true }
    }

    private func commitTag() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            withAnimation { tags.append(trimmed) }
        }
        inputText = ""
    }
}

// MARK: - Chip inside the input area

private struct InputTagChip: View {
    let name: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 3) {
            Text(name)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
        }
        .font(.callout)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.tint.opacity(0.15))
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
        for (index, placement) in result.placements.enumerated() {
            let size = subviews[index].sizeThatFits(.unspecified)
            // Vertically center each item within its row
            let yOffset = (placement.rowHeight - size.height) / 2
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + placement.position.x,
                    y: bounds.minY + placement.position.y + yOffset
                ),
                proposal: .unspecified
            )
        }
    }

    private struct Placement {
        var position: CGPoint
        var rowHeight: CGFloat
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews)
        -> (size: CGSize, placements: [Placement])
    {
        let maxWidth = proposal.width ?? .infinity
        var placements: [Placement] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0
        var rowStartIndex = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                // Finalize previous row: update rowHeight for all items in that row
                for i in rowStartIndex..<index {
                    placements[i].rowHeight = rowHeight
                }
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
                rowStartIndex = index
            }
            placements.append(Placement(position: CGPoint(x: x, y: y), rowHeight: 0))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }
        // Finalize last row
        for i in rowStartIndex..<placements.count {
            placements[i].rowHeight = rowHeight
        }

        return (CGSize(width: maxX, height: y + rowHeight), placements)
    }
}
