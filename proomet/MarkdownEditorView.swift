import SwiftUI
import AppKit

struct MarkdownEditorView: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.delegate = context.coordinator
        textView.string = text
        context.coordinator.applyHighlighting(to: textView)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
            context.coordinator.applyHighlighting(to: textView)
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        nonisolated func textDidChange(_ notification: Notification) {
            MainActor.assumeIsolated {
                guard let textView = notification.object as? NSTextView else { return }
                text.wrappedValue = textView.string
                applyHighlighting(to: textView)
            }
        }

        func applyHighlighting(to textView: NSTextView) {
            guard let storage = textView.textStorage else { return }
            let string = textView.string
            let fullRange = NSRange(location: 0, length: (string as NSString).length)
            guard fullRange.length > 0 else { return }

            storage.beginEditing()

            // Reset to default style
            storage.addAttributes([
                .foregroundColor: NSColor.textColor,
                .backgroundColor: NSColor.clear,
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
            ], range: fullRange)

            // Highlight {{variable}} placeholders
            let pattern = "\\{\\{\\s*[\\w][\\w\\s]*?\\s*\\}\\}"
            if let regex = try? NSRegularExpression(pattern: pattern) {
                for match in regex.matches(in: string, range: fullRange) {
                    storage.addAttributes([
                        .foregroundColor: NSColor.systemTeal,
                        .backgroundColor: NSColor.systemTeal.withAlphaComponent(0.1)
                    ], range: match.range)
                }
            }

            storage.endEditing()
        }
    }
}
