import SwiftData
import Foundation

@Model
final class PromptVersion {
    var id: UUID = UUID()
    var content: String = ""
    var title: String = ""
    var message: String?
    var branchName: String?
    var createdAt: Date = Date()

    var prompt: PromptItem?
    var parentVersion: PromptVersion?
    var mergeParentId: UUID?

    @Relationship(deleteRule: .noAction, inverse: \PromptVersion.parentVersion)
    var childVersions: [PromptVersion] = []

    init(content: String, title: String, message: String? = nil) {
        self.content = content
        self.title = title
        self.message = message
    }
}
