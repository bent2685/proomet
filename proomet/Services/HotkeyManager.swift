import AppKit
import Carbon

@Observable
class HotkeyManager {
    static let shared = HotkeyManager()

    var isRegistered = false
    var registrationError: String?

    var onHotkeyPressed: (() -> Void)?

    private var globalMonitor: Any?
    private var localMonitor: Any?

    // Default: Control+Cmd+P
    private(set) var modifierFlags: UInt = NSEvent.ModifierFlags([.control, .command]).rawValue {
        didSet { UserDefaults.standard.set(modifierFlags, forKey: "hotkeyModifierFlags") }
    }
    private(set) var keyCode: UInt16 = 35 { // 'P'
        didSet { UserDefaults.standard.set(Int(keyCode), forKey: "hotkeyKeyCode") }
    }

    private init() {
        if let stored = UserDefaults.standard.object(forKey: "hotkeyModifierFlags") as? UInt {
            modifierFlags = stored
        }
        if let stored = UserDefaults.standard.object(forKey: "hotkeyKeyCode") as? Int {
            keyCode = UInt16(stored)
        }
    }

    func register() {
        unregister()

        if !AccessibilityHelper.isTrusted {
            isRegistered = false
            registrationError = "需要辅助功能权限才能使用全局快捷键"
            return
        }

        let expectedModifiers = NSEvent.ModifierFlags(rawValue: modifierFlags)
            .intersection(.deviceIndependentFlagsMask)

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event, expectedModifiers: expectedModifiers)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event, expectedModifiers: expectedModifiers)
            return event
        }

        if globalMonitor != nil {
            isRegistered = true
            registrationError = nil
        } else {
            isRegistered = false
            registrationError = "快捷键注册失败，请检查辅助功能权限"
        }
    }

    func unregister() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        globalMonitor = nil
        localMonitor = nil
        isRegistered = false
    }

    func updateHotkey(modifierFlags: UInt, keyCode: UInt16) {
        self.modifierFlags = modifierFlags
        self.keyCode = keyCode
        register()
    }

    // MARK: - Private

    private func handleKeyEvent(_ event: NSEvent, expectedModifiers: NSEvent.ModifierFlags) {
        let currentModifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if event.keyCode == keyCode && currentModifiers == expectedModifiers {
            onHotkeyPressed?()
        }
    }
}
