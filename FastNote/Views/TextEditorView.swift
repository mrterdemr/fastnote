import SwiftUI
import AppKit

struct TextEditorView: NSViewRepresentable {
    @ObservedObject var document: NoteDocument
    @ObservedObject var settings: EditorSettings
    let store: DocumentStore

    func makeCoordinator() -> Coordinator {
        Coordinator(document: document, store: store)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = false

        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }

        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.allowsUndo = true
        textView.font = settings.effectiveFont
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 6, height: 8)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        textView.string = document.text

        let length = (document.text as NSString).length
        let caret = min(document.selectedRange.location, length)
        textView.setSelectedRange(NSRange(location: caret, length: 0))

        context.coordinator.textView = textView
        store.activeTextView = textView

        applyWordWrap(document.wordWrap, textView: textView, scrollView: scrollView)
        context.coordinator.appliedWordWrap = document.wordWrap
        context.coordinator.updateCursorPosition()

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        context.coordinator.document = document
        store.activeTextView = textView

        if textView.string != document.text {
            textView.string = document.text
        }
        if context.coordinator.appliedWordWrap != document.wordWrap {
            applyWordWrap(document.wordWrap, textView: textView, scrollView: scrollView)
            context.coordinator.appliedWordWrap = document.wordWrap
        }
        let newFont = settings.effectiveFont
        if textView.font != newFont {
            textView.font = newFont
        }
    }

    private func applyWordWrap(_ wrap: Bool, textView: NSTextView, scrollView: NSScrollView) {
        guard let container = textView.textContainer else { return }
        let huge = CGFloat.greatestFiniteMagnitude

        if wrap {
            scrollView.hasHorizontalScroller = false
            textView.isHorizontallyResizable = false
            textView.autoresizingMask = [.width]
            let contentWidth = scrollView.contentSize.width
            textView.setFrameSize(NSSize(width: contentWidth, height: textView.frame.height))
            container.widthTracksTextView = true
            container.containerSize = NSSize(width: contentWidth, height: huge)
        } else {
            scrollView.hasHorizontalScroller = true
            textView.isHorizontallyResizable = true
            textView.autoresizingMask = []
            textView.maxSize = NSSize(width: huge, height: huge)
            container.widthTracksTextView = false
            container.containerSize = NSSize(width: huge, height: huge)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var document: NoteDocument
        let store: DocumentStore
        weak var textView: NSTextView?
        var appliedWordWrap: Bool?

        init(document: NoteDocument, store: DocumentStore) {
            self.document = document
            self.store = store
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = textView else { return }
            if document.text != textView.string {
                document.text = textView.string
            }
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = textView else { return }
            document.selectedRange = textView.selectedRange()
            updateCursorPosition()
        }

        func updateCursorPosition() {
            guard let textView = textView else { return }
            let text = textView.string as NSString
            let location = min(textView.selectedRange().location, text.length)
            var line = 1
            var column = 1
            var index = 0
            while index < location {
                if text.character(at: index) == 0x0A {
                    line += 1
                    column = 1
                } else {
                    column += 1
                }
                index += 1
            }
            if store.cursorLine != line { store.cursorLine = line }
            if store.cursorColumn != column { store.cursorColumn = column }
        }
    }
}
