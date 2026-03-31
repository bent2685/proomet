import SwiftUI
import SwiftData

struct QuickPanelResultRow: View {
    let title: String
    let categoryName: String?
    let tags: [String]
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let categoryName, !categoryName.isEmpty {
                        Text(categoryName)
                            .font(.system(size: 11))
                            .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                    ForEach(tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 10))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(isSelected ? .white.opacity(0.2) : Color.secondary.opacity(0.15))
                            .foregroundStyle(isSelected ? .white.opacity(0.9) : .secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct QuickPanelFilterRow: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 14))
                .foregroundStyle(isSelected ? .white : .primary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isSelected ? Color.accentColor : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}
