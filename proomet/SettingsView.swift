import SwiftUI
import Carbon

struct SettingsView: View {
    @State private var launchManager = LaunchAtLoginManager()
    private var hotkeyManager: HotkeyManager { HotkeyManager.shared }
    @State private var isRecordingHotkey = false
    @State private var hotkeyMonitor: Any?

    var body: some View {
        Form {
            Section("快捷键") {
                HStack {
                    Text("呼出快捷面板")
                    Spacer()
                    hotkeyButton
                }

                if let error = hotkeyManager.registrationError {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 12))
                }
            }

            Section("通用") {
                Toggle("开机自启动", isOn: Binding(
                    get: { launchManager.isEnabled },
                    set: { launchManager.setEnabled($0) }
                ))
            }

            Section("辅助功能") {
                HStack {
                    if AccessibilityHelper.isTrusted {
                        Label("已授权", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Label("未授权 — 全局快捷键和自动粘贴需要此权限", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    Button("打开系统设置") {
                        AccessibilityHelper.openAccessibilitySettings()
                    }
                }
                .font(.system(size: 12))
            }
        }
        .formStyle(.grouped)
        .frame(width: 450, height: 280)
    }

    // MARK: - Hotkey Button

    private var hotkeyButton: some View {
        Button {
            if isRecordingHotkey {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            if isRecordingHotkey {
                Text("按下新快捷键...")
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                Text(hotkeyDisplayString)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .buttonStyle(.plain)
    }

    private var hotkeyDisplayString: String {
        let flags = NSEvent.ModifierFlags(rawValue: hotkeyManager.modifierFlags)
        var parts: [String] = []
        if flags.contains(.control) { parts.append("⌃") }
        if flags.contains(.option) { parts.append("⌥") }
        if flags.contains(.shift) { parts.append("⇧") }
        if flags.contains(.command) { parts.append("⌘") }
        parts.append(keyCodeToString(hotkeyManager.keyCode))
        return parts.joined()
    }

    // MARK: - Recording

    private func startRecording() {
        isRecordingHotkey = true
        hotkeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            // Require at least one modifier
            guard !modifiers.isEmpty else {
                if event.keyCode == 53 { // Escape
                    stopRecording()
                }
                return nil
            }
            hotkeyManager.updateHotkey(
                modifierFlags: modifiers.rawValue,
                keyCode: event.keyCode
            )
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecordingHotkey = false
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            hotkeyMonitor = nil
        }
    }

    // MARK: - Key Code Display

    private func keyCodeToString(_ keyCode: UInt16) -> String {
        let specialKeys: [UInt16: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 49: "Space", 50: "`",
            36: "↩", 48: "⇥", 51: "⌫", 53: "⎋",
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        return specialKeys[keyCode] ?? "Key\(keyCode)"
    }
}
