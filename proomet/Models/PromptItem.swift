import SwiftData
import Foundation

@Model
final class PromptItem {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var tags: [String] = []
    var category: PromptCategory?
    var useCount: Int = 0
    var lastUsedAt: Date?
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var currentVersionId: UUID?

    @Relationship(deleteRule: .cascade, inverse: \PromptVersion.prompt)
    var versions: [PromptVersion] = []

    init(title: String, content: String = "") {
        self.title = title
        self.content = content
    }
}
