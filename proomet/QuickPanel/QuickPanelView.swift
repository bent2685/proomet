import SwiftUI
import SwiftData

enum QuickPanelFilterMode: Hashable {
    case all
    case category
    case tag
}

struct QuickPanelView: View {
    var manager: QuickPanelManager

    @Query(sort: \PromptItem.updatedAt, order: .reverse) private var allPrompts: [PromptItem]
    @Query(sort: \PromptCategory.sortOrder) private var categories: [PromptCategory]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var filterMode: QuickPanelFilterMode = .all
    @State private var selectedCategory: PromptCategory?
    @State private var selectedTag: String?
    @State private var filterSelectionIndex = 0
    @FocusState private var isSearchFocused: Bool

    // MARK: - Computed

    /// 检测输入法是否正在组合输入（如中文拼音候选状态）
    private var isIMEComposing: Bool {
        NSTextInputContext.current?.client.hasMarkedText() ?? false
    }

    private var usedTags: [String] {
        Array(Set(allPrompts.flatMap(\.tags))).sorted()
    }

    private var filteredPrompts: [PromptItem] {
        var base = allPrompts

        if let selectedCategory {
            base = base.filter { $0.category?.id == selectedCategory.id }
        }
        if let selectedTag {
            base = base.filter { $0.tags.contains(selectedTag) }
        }

        if searchText.isEmpty {
            // 无搜索时按使用权重排序
            return Array(base.sorted { usageWeight($0) > usageWeight($1) }.prefix(8))
        }

        // 搜索时：标题命中 > 内容命中，同级按权重排序
        var titleMatches: [PromptItem] = []
        var contentMatches: [PromptItem] = []
        for item in base {
            if fuzzyMatch(query: searchText, in: item.title) {
                titleMatches.append(item)
            } else if fuzzyMatch(query: searchText, in: item.content) {
                contentMatches.append(item)
            }
        }
        titleMatches.sort { usageWeight($0) > usageWeight($1) }
        contentMatches.sort { usageWeight($0) > usageWeight($1) }
        return Array((titleMatches + contentMatches).prefix(8))
    }

    private var selectedPrompt: PromptItem? {
        guard !filteredPrompts.isEmpty, selectedIndex < filteredPrompts.count else { return nil }
        return filteredPrompts[selectedIndex]
    }

    private var isInFilterSelection: Bool {
        filterMode == .category || filterMode == .tag
    }

    private var activeFilterLabel: String? {
        if let selectedCategory {
            return "分类: \(selectedCategory.name)"
        }
        if let selectedTag {
            return "标签: \(selectedTag)"
        }
        return nil
    }

    // MARK: - Body

    var body: some View {
        panelContent
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
            )
            .onAppear {
                isSearchFocused = true
            }
            .onChange(of: manager.isVisible) { _, isVisible in
                if isVisible {
                    resetState()
                    isSearchFocused = true
                }
            }
            .onChange(of: searchText) {
                selectedIndex = 0
            }
            .onKeyPress(.upArrow) {
                guard !isIMEComposing else { return .ignored }
                handleArrowUp(); return .handled
            }
            .onKeyPress(.downArrow) {
                guard !isIMEComposing else { return .ignored }
                handleArrowDown(); return .handled
            }
            .onKeyPress(.return) {
                guard !isIMEComposing else { return .ignored }
                handleReturn(); return .handled
            }
            .onKeyPress(.escape) { handleEscape(); return .handled }
            .onKeyPress(characters: .alphanumerics, phases: .down) { keyPress in
                handleModifierKeyPress(keyPress)
            }
    }

    private var panelContent: some View {
        VStack(spacing: 0) {
            searchBar
            mainContent
                .id(filterMode)
            Divider()
            QuickPanelHintBar()
        }
    }

    private var searchBar: some View {
        VStack(spacing: 0) {
            QuickPanelSearchField(text: $searchText, isFocused: $isSearchFocused)
            filterBadge
            Divider()
        }
    }

    @ViewBuilder
    private var filterBadge: some View {
        if let label = activeFilterLabel {
            HStack {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Button {
                    switchToAll()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 6)
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if isInFilterSelection {
            filterSelectionContent
        } else {
            promptListContent
        }
    }

    // MARK: - Sub Views

    @ViewBuilder
    private var promptListContent: some View {
        if filteredPrompts.isEmpty {
            HStack {
                Text("无匹配结果")
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider()

                QuickPanelPreview(content: nil)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(minHeight: 100)
        } else {
            HStack(spacing: 0) {
                // Left: result list
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(Array(filteredPrompts.enumerated()), id: \.element.id) { index, prompt in
                                QuickPanelResultRow(
                                    title: prompt.title.isEmpty ? "无标题" : prompt.title,
                                    categoryName: prompt.category?.name,
                                    tags: prompt.tags,
                                    isSelected: index == selectedIndex
                                )
                                .id(prompt.id)
                                .onTapGesture {
                                    selectedIndex = index
                                }
                                .onTapGesture(count: 2) {
                                    selectedIndex = index
                                    handleReturn()
                                }
                            }
                        }
                        .padding(6)
                    }
                    .onChange(of: selectedIndex) { _, newIndex in
                        if let prompt = filteredPrompts[safe: newIndex] {
                            withAnimation(.easeOut(duration: 0.1)) {
                                proxy.scrollTo(prompt.id, anchor: .center)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Divider()

                // Right: preview
                QuickPanelPreview(content: selectedPrompt?.content)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var filterSelectionContent: some View {
        let items: [String] = filterMode == .category
            ? categories.map(\.name)
            : usedTags

        if items.isEmpty {
            Text(filterMode == .category ? "暂无分类" : "暂无标签")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minHeight: 100)
        } else {
            HStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(items.enumerated()), id: \.element) { index, name in
                            QuickPanelFilterRow(
                                name: name,
                                isSelected: index == filterSelectionIndex
                            )
                            .onTapGesture {
                                filterSelectionIndex = index
                                applyFilterSelection()
                            }
                        }
                    }
                    .padding(6)
                }
                .frame(maxWidth: .infinity)

                Divider()

                VStack {
                    Text(filterMode == .category ? "选择分类" : "选择标签")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Text("↑↓ 选择，⏎ 确认，⎋ 取消")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Actions

    private func handleModifierKeyPress(_ keyPress: KeyPress) -> KeyPress.Result {
        guard keyPress.modifiers == .command else { return .ignored }
        switch keyPress.characters {
        case "1": switchToAll(); return .handled
        case "2": switchToCategoryFilter(); return .handled
        case "3": switchToTagFilter(); return .handled
        default: return .ignored
        }
    }

    private func handleArrowUp() {
        if isInFilterSelection {
            let items = filterMode == .category ? categories.count : usedTags.count
            if filterSelectionIndex > 0 {
                filterSelectionIndex -= 1
            } else {
                filterSelectionIndex = max(items - 1, 0)
            }
        } else {
            if selectedIndex > 0 {
                selectedIndex -= 1
            } else {
                selectedIndex = max(filteredPrompts.count - 1, 0)
            }
        }
    }

    private func handleArrowDown() {
        if isInFilterSelection {
            let items = filterMode == .category ? categories.count : usedTags.count
            if filterSelectionIndex < items - 1 {
                filterSelectionIndex += 1
            } else {
                filterSelectionIndex = 0
            }
        } else {
            if selectedIndex < filteredPrompts.count - 1 {
                selectedIndex += 1
            } else {
                selectedIndex = 0
            }
        }
    }

    private func handleReturn() {
        if isInFilterSelection {
            applyFilterSelection()
            return
        }

        guard let prompt = selectedPrompt else { return }
        pastePrompt(prompt)
    }

    private func handleEscape() {
        if isInFilterSelection {
            exitFilterSelection()
            return
        }
        manager.hide()
    }

    private func switchToAll() {
        selectedCategory = nil
        selectedTag = nil
        filterSelectionIndex = 0
        selectedIndex = 0
        filterMode = .all
    }

    private func switchToCategoryFilter() {
        filterSelectionIndex = 0
        filterMode = .category
    }

    private func switchToTagFilter() {
        filterSelectionIndex = 0
        filterMode = .tag
    }

    /// Cancel filter selection without applying, go back to prompt list
    private func exitFilterSelection() {
        filterSelectionIndex = 0
        filterMode = .all
    }

    private func applyFilterSelection() {
        if filterMode == .category {
            guard filterSelectionIndex < categories.count else { return }
            selectedCategory = categories[filterSelectionIndex]
            selectedTag = nil
        } else if filterMode == .tag {
            guard filterSelectionIndex < usedTags.count else { return }
            selectedTag = usedTags[filterSelectionIndex]
            selectedCategory = nil
        }
        filterSelectionIndex = 0
        selectedIndex = 0
        filterMode = .all
    }

    private func pastePrompt(_ prompt: PromptItem) {
        // Update usage stats
        prompt.useCount += 1
        prompt.lastUsedAt = Date()
        try? modelContext.save()

        // Hide panel, restore previous app, and paste
        manager.hideAndPaste(content: prompt.content)
    }

    private func resetState() {
        searchText = ""
        selectedIndex = 0
        filterMode = .all
        selectedCategory = nil
        selectedTag = nil
        filterSelectionIndex = 0
    }

    // MARK: - Weight & Match

    /// 使用权重：综合使用次数和最近使用时间
    private func usageWeight(_ item: PromptItem) -> Double {
        let countScore = Double(item.useCount)
        let recencyScore: Double
        if let lastUsed = item.lastUsedAt {
            let hoursAgo = Date().timeIntervalSince(lastUsed) / 3600
            // 越近使用衰减越少，24h 内权重高
            recencyScore = max(0, 10 - hoursAgo / 2.4)
        } else {
            recencyScore = 0
        }
        return countScore + recencyScore
    }

    private func fuzzyMatch(query: String, in string: String) -> Bool {
        let queryLower = query.lowercased()
        let stringLower = string.lowercased()
        var queryIdx = queryLower.startIndex
        var stringIdx = stringLower.startIndex

        while queryIdx < queryLower.endIndex && stringIdx < stringLower.endIndex {
            if queryLower[queryIdx] == stringLower[stringIdx] {
                queryIdx = queryLower.index(after: queryIdx)
            }
            stringIdx = stringLower.index(after: stringIdx)
        }
        return queryIdx == queryLower.endIndex
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
