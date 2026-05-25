import SwiftUI

struct StatusBarView: View {
    @ObservedObject var store: DocumentStore
    @ObservedObject var document: NoteDocument
    @ObservedObject var settings: EditorSettings

    private var characterCount: Int {
        (document.text as NSString).length
    }

    private var wordCount: Int {
        document.text.split { $0.isWhitespace || $0.isNewline }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("Line \(store.cursorLine), Column \(store.cursorColumn)")

            Spacer()

            Text("\(characterCount) characters")
            Text("\(wordCount) words")

            if abs(settings.zoom - 1.0) > 0.001 {
                Divider().frame(height: 12)
                Text(verbatim: "\(Int((settings.zoom * 100).rounded()))%")
            }

            Divider().frame(height: 12)

            Toggle("Word Wrap", isOn: $document.wordWrap)
                .toggleStyle(.checkbox)
                .controlSize(.small)
        }
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
        .frame(height: 24)
    }
}
