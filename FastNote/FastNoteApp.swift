import SwiftUI
import AppKit
import Combine

@main
struct FastNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var store = DocumentStore.shared
    @StateObject private var settings = EditorSettings.shared

    init() {
        LanguageMode.current.apply()
    }

    var body: some Scene {
        WindowGroup("FastNote") {
            ContentView(store: store)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New") { store.newDocument() }
                    .keyboardShortcut("n", modifiers: .command)
                Button("Open…") { store.openFile() }
                    .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(replacing: .saveItem) {
                Button("Save") { store.save() }
                    .keyboardShortcut("s", modifiers: .command)
                Button("Save As…") { store.saveAs() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            CommandGroup(replacing: .printItem) {
                Button("Page Setup…") { store.showPageSetup() }
                    .keyboardShortcut("p", modifiers: [.command, .shift])
                Button("Print…") { store.printDocument() }
                    .keyboardShortcut("p", modifiers: .command)
            }
            CommandGroup(after: .textEditing) {
                Divider()
                Button("Find…") { store.showFindBar() }
                    .keyboardShortcut("f", modifiers: .command)
                Button("Find and Replace…") { store.showReplaceBar() }
                    .keyboardShortcut("f", modifiers: [.command, .option])
                Divider()
                Button("Go to Line…") { store.goToLine() }
                    .keyboardShortcut("l", modifiers: .command)
                Button("Insert Date and Time") { store.insertDateTime() }
                    .keyboardShortcut("t", modifiers: [.command, .shift])
                Button("Pick Screen Color…") { store.pickColorFromScreen() }
                    .keyboardShortcut("h", modifiers: [.command, .shift])
            }
            CommandGroup(after: .toolbar) {
                Button("Zoom In") { settings.zoomIn() }
                    .keyboardShortcut("=", modifiers: .command)
                Button("Zoom Out") { settings.zoomOut() }
                    .keyboardShortcut("-", modifiers: .command)
                Button("Actual Size") { settings.resetZoom() }
                    .keyboardShortcut("0", modifiers: .command)
                Divider()
            }
            CommandMenu("Format") {
                Button("Word Wrap") { store.toggleWordWrap() }
                    .keyboardShortcut("z", modifiers: [.command, .option])
            }
        }

        Settings {
            SettingsView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static private(set) weak var shared: AppDelegate?

    weak var mainWindow: NSWindow?

    private var docSubscription: AnyCancellable?
    private var isModifiedSubscription: AnyCancellable?

    override init() {
        super.init()
        Self.shared = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        AppearanceMode.current.apply()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        DocumentStore.shared.confirmDiscardIfNeeded() ? .terminateNow : .terminateCancel
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        DocumentStore.shared.open(url: url)
    }

    func attach(window: NSWindow) {
        guard mainWindow !== window else { return }
        mainWindow = window
        window.delegate = self
        observeDocumentEdited()
    }

    private func observeDocumentEdited() {
        docSubscription = DocumentStore.shared.$document
            .sink { [weak self] doc in
                guard let self = self else { return }
                self.applyEdited(doc.isModified)
                self.isModifiedSubscription = doc.$isModified
                    .sink { [weak self] modified in
                        self?.applyEdited(modified)
                    }
            }
    }

    private func applyEdited(_ modified: Bool) {
        mainWindow?.isDocumentEdited = modified
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        DocumentStore.shared.confirmDiscardIfNeeded()
    }
}
