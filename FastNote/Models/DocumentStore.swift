import Foundation
import AppKit
import UniformTypeIdentifiers

final class DocumentStore: ObservableObject {
    static let shared = DocumentStore()

    @Published var document: NoteDocument = NoteDocument()

    @Published var cursorLine: Int = 1
    @Published var cursorColumn: Int = 1

    weak var activeTextView: NSTextView?

    func newDocument() {
        guard confirmDiscardIfNeeded() else { return }
        document = NoteDocument()
    }

    func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .text, .utf8PlainText]
        panel.allowsOtherFileTypes = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        open(url: url)
    }

    func open(url: URL) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            presentError(String(format: NSLocalizedString("Could not open \"%@\".", comment: ""), url.lastPathComponent))
            return
        }
        guard confirmDiscardIfNeeded() else { return }
        document = NoteDocument(text: content, fileURL: url, isModified: false)
    }

    func confirmDiscardIfNeeded() -> Bool {
        guard document.isModified else { return true }
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Unsaved Changes", comment: "")
        alert.informativeText = NSLocalizedString("Do you want to save your changes?", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Save", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Don't Save", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            save()
            return !document.isModified
        case .alertSecondButtonReturn:
            document.isModified = false
            return true
        default:
            return false
        }
    }

    func save() {
        guard let url = document.fileURL else {
            saveAs()
            return
        }
        do {
            try document.text.write(to: url, atomically: true, encoding: .utf8)
            document.isModified = false
        } catch {
            presentError(String(format: NSLocalizedString("Could not save: %@", comment: ""), error.localizedDescription))
        }
    }

    func saveAs() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsOtherFileTypes = true
        panel.nameFieldStringValue = document.fileURL?.lastPathComponent ?? NSLocalizedString("Untitled.txt", comment: "")
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try document.text.write(to: url, atomically: true, encoding: .utf8)
            document.fileURL = url
            document.isModified = false
        } catch {
            presentError(String(format: NSLocalizedString("Could not save: %@", comment: ""), error.localizedDescription))
        }
    }

    func showFindBar() { performFinder(.showFindInterface) }
    func showReplaceBar() { performFinder(.showReplaceInterface) }

    private func performFinder(_ action: NSTextFinder.Action) {
        guard let textView = activeTextView else { return }
        textView.window?.makeFirstResponder(textView)
        let item = NSMenuItem()
        item.tag = action.rawValue
        textView.performTextFinderAction(item)
    }

    func toggleWordWrap() {
        document.wordWrap.toggle()
    }

    func goToLine() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Go to Line", comment: "")
        alert.informativeText = NSLocalizedString("Enter a line number.", comment: "")
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        field.placeholderString = "1"
        alert.accessoryView = field
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        alert.window.initialFirstResponder = field

        guard alert.runModal() == .alertFirstButtonReturn,
              let target = Int(field.stringValue), target >= 1,
              let textView = activeTextView else { return }

        let text = textView.string as NSString
        var line = 1
        var lineStartIndex = 0
        var index = 0
        while index < text.length && line < target {
            if text.character(at: index) == 0x0A {
                line += 1
                lineStartIndex = index + 1
            }
            index += 1
        }
        if line < target {
            lineStartIndex = text.length
        }
        let range = NSRange(location: lineStartIndex, length: 0)
        textView.setSelectedRange(range)
        textView.scrollRangeToVisible(range)
        textView.window?.makeFirstResponder(textView)
    }

    func insertDateTime() {
        guard let textView = activeTextView else { return }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let stamp = formatter.string(from: Date())
        textView.insertText(stamp, replacementRange: textView.selectedRange())
    }

    func pickColorFromScreen() {
        let sampler = NSColorSampler()
        sampler.show { [weak self] color in
            guard let self = self, let color = color,
                  let rgb = color.usingColorSpace(.sRGB),
                  let textView = self.activeTextView else { return }
            let hex = String(format: "#%02X%02X%02X",
                             Int((rgb.redComponent * 255).rounded()),
                             Int((rgb.greenComponent * 255).rounded()),
                             Int((rgb.blueComponent * 255).rounded()))
            textView.insertText(hex, replacementRange: textView.selectedRange())
        }
    }

    func printDocument() {
        guard let textView = activeTextView else { return }
        let operation = NSPrintOperation(view: textView)
        operation.printPanel.options = [
            .showsCopies, .showsPageRange, .showsPaperSize,
            .showsOrientation, .showsScaling
        ]
        operation.run()
    }

    func showPageSetup() {
        let layout = NSPageLayout()
        layout.runModal(with: NSPrintInfo.shared)
    }

    private func presentError(_ message: String) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.runModal()
    }
}
