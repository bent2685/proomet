import SwiftData
import Foundation

@Model
final class PromptCategory {
    var id: UUID = UUID()
    var name: String = ""
    var sortOrder: Int = 0
    var isDefault: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \PromptItem.category)
    var prompts: [PromptItem] = []

    init(name: String, sortOrder: Int, isDefault: Bool = false) {
        self.name = name
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }
}
