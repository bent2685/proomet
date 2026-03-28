import Foundation

enum SidebarSelection: Hashable {
    case allPrompts
    case recent
    case category(PromptCategory)
    case tag(String)
}
