import SwiftUI
import SwiftData

@main
struct proometApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([PromptItem.self, PromptVersion.self, PromptCategory.self])
        let config = ModelConfiguration(schema: schema)
        container = try! ModelContainer(for: schema, configurations: [config])

        // Seed default categories on first launch
        let context = container.mainContext
        let descriptor = FetchDescriptor<PromptCategory>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        if count == 0 {
            context.insert(PromptCategory(name: "常用", sortOrder: 0, isDefault: true))
            context.insert(PromptCategory(name: "人设", sortOrder: 1, isDefault: true))
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
        .defaultSize(width: 1000, height: 680)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About proomet") {
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .credits: NSAttributedString(
                            string: "GitHub: https://github.com/bent2685/proomet",
                            attributes: [
                                .font: NSFont.systemFont(ofSize: 11),
                                .link: URL(string: "https://github.com/bent2685/proomet")!
                            ]
                        ),
                        .version: "beta"
                    ])
                }
            }
        }
    }
}
