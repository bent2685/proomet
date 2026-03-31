import SwiftUI
import SwiftData

@main
struct proometApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let container: ModelContainer
    @State private var quickPanelManager: QuickPanelManager
    private var hotkeyManager: HotkeyManager { HotkeyManager.shared }

    init() {
        let schema = Schema([PromptItem.self, PromptVersion.self, PromptCategory.self])
        let config = ModelConfiguration(schema: schema)
        let container = try! ModelContainer(for: schema, configurations: [config])
        self.container = container
        self._quickPanelManager = State(initialValue: QuickPanelManager(modelContainer: container))

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
                .onAppear {
                    setupHotkey()
                }
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

        MenuBarExtra("Proomet", systemImage: "text.bubble") {
            Button("显示主页面") {
                showMainWindow()
            }
            Button("显示快捷面板") {
                quickPanelManager.toggle()
            }
            Divider()
            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
        }

        Settings {
            SettingsView()
        }
    }

    private func showMainWindow() {
        NSApplication.shared.activate(ignoringOtherApps: true)
        if let window = NSApplication.shared.windows.first(where: { !($0 is NSPanel) }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    private func setupHotkey() {
        hotkeyManager.onHotkeyPressed = { [quickPanelManager] in
            quickPanelManager.toggle()
        }
        hotkeyManager.register()
    }
}
