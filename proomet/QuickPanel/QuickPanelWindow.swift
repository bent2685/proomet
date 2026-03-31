import AppKit
import SwiftUI
import SwiftData

// MARK: - NSPanel Subclass

class QuickPanelWindow: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )

        level = .floating
        isMovableByWindowBackground = false
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// MARK: - QuickPanelManager

@Observable
class QuickPanelManager {
    private var panel: QuickPanelWindow?
    private let modelContainer: ModelContainer
    private(set) var isVisible = false
    private var previousApp: NSRunningApplication?

    private let panelWidth: CGFloat = 680
    private let panelHeight: CGFloat = 420

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        // Remember the previously active app before we steal focus
        previousApp = NSWorkspace.shared.frontmostApplication

        if panel == nil {
            createPanel()
        }
        positionPanel()

        // Scale-in animation
        panel?.alphaValue = 0
        let targetFrame = panel!.frame
        let smallFrame = targetFrame.insetBy(dx: targetFrame.width * 0.02, dy: targetFrame.height * 0.02)
        panel?.setFrame(smallFrame, display: false)
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel?.animator().alphaValue = 1
            panel?.animator().setFrame(targetFrame, display: true)
        }

        isVisible = true
    }

    func hide() {
        guard let panel, isVisible else { return }
        isVisible = false
        let currentFrame = panel.frame

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            let smallFrame = currentFrame.insetBy(dx: currentFrame.width * 0.02, dy: currentFrame.height * 0.02)
            panel.animator().alphaValue = 0
            panel.animator().setFrame(smallFrame, display: true)
        }, completionHandler: { [weak self] in
            panel.orderOut(nil)
            self?.restorePreviousApp()
        })
    }

    /// Hide immediately (no animation) and paste content to the previous app
    func hideAndPaste(content: String) {
        guard let panel, isVisible else { return }
        isVisible = false

        // Immediately hide — no animation, so the previous app gets focus ASAP
        panel.orderOut(nil)

        // Copy to clipboard first
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)

        // Reactivate the previous app, then simulate Cmd+V
        restorePreviousApp()

        if AccessibilityHelper.isTrusted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                PasteService.simulateCmdV()
            }
        }
    }

    private func restorePreviousApp() {
        if let app = previousApp, !app.isTerminated {
            app.activate()
        }
        previousApp = nil
    }

    // MARK: - Private

    private func createPanel() {
        let rect = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        let panelWindow = QuickPanelWindow(contentRect: rect)

        let rootView = QuickPanelView(manager: self)
            .modelContainer(modelContainer)

        panelWindow.contentView = NSHostingView(rootView: rootView)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidResignKey),
            name: NSWindow.didResignKeyNotification,
            object: panelWindow
        )

        panel = panelWindow
    }

    private func positionPanel() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - panelWidth / 2
        let y = screenFrame.maxY - panelHeight - 100
        panel?.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: false)
    }

    @objc private func panelDidResignKey(_ notification: Notification) {
        hide()
    }
}
