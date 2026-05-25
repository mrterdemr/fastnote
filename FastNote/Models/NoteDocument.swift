import Foundation

final class NoteDocument: ObservableObject, Identifiable {
    let id: UUID

    @Published var text: String {
        didSet {
            if text != oldValue { isModified = true }
        }
    }
    @Published var fileURL: URL?
    @Published var isModified: Bool
    @Published var wordWrap: Bool

    var selectedRange: NSRange

    init(
        id: UUID = UUID(),
        text: String = "",
        fileURL: URL? = nil,
        isModified: Bool = false,
        wordWrap: Bool = true,
        selectedRange: NSRange = NSRange(location: 0, length: 0)
    ) {
        self.id = id
        self.text = text
        self.fileURL = fileURL
        self.isModified = isModified
        self.wordWrap = wordWrap
        self.selectedRange = selectedRange
    }

    var displayName: String {
        fileURL?.lastPathComponent ?? NSLocalizedString("Untitled", comment: "")
    }
}
