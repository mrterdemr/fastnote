import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var store: DocumentStore
    @ObservedObject var settings: EditorSettings = .shared

    var body: some View {
        DocumentView(document: store.document, store: store, settings: settings)
            .id(store.document.id)
            .background(TitlebarMaterialBackground().ignoresSafeArea())
            .background(WindowAccessor { window in
                guard let window = window else { return }
                AppDelegate.shared?.attach(window: window)
            })
    }
}

private struct TitlebarMaterialBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .titlebar
        view.blendingMode = .behindWindow
        view.state = .followsWindowActiveState
        return view
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

private struct DocumentView: View {
    @ObservedObject var document: NoteDocument
    @ObservedObject var store: DocumentStore
    @ObservedObject var settings: EditorSettings

    var body: some View {
        VStack(spacing: 0) {
            TextEditorView(document: document, settings: settings, store: store)
            Divider()
            StatusBarView(store: store, document: document, settings: settings)
        }
        .frame(minWidth: 560, minHeight: 320)
        .navigationTitle(document.displayName)
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onWindow: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        Reporter(onWindow: onWindow)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    final class Reporter: NSView {
        let onWindow: (NSWindow?) -> Void

        init(onWindow: @escaping (NSWindow?) -> Void) {
            self.onWindow = onWindow
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            onWindow(window)
        }
    }
}
