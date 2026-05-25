import Foundation
import AppKit

final class EditorSettings: NSObject, ObservableObject {
    static let shared = EditorSettings()

    private static let zoomKey = "editor.zoom"
    private static let fontNameKey = "editor.fontName"
    private static let fontSizeKey = "editor.fontSize"

    @Published var zoom: Double {
        didSet {
            zoom = max(0.5, min(3.0, zoom))
            UserDefaults.standard.set(zoom, forKey: Self.zoomKey)
        }
    }

    @Published var fontName: String {
        didSet { UserDefaults.standard.set(fontName, forKey: Self.fontNameKey) }
    }

    @Published var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: Self.fontSizeKey) }
    }

    override init() {
        let defaults = UserDefaults.standard
        let storedZoom = defaults.double(forKey: Self.zoomKey)
        zoom = storedZoom > 0 ? storedZoom : 1.0
        fontName = defaults.string(forKey: Self.fontNameKey) ?? "Menlo-Regular"
        let storedSize = defaults.double(forKey: Self.fontSizeKey)
        fontSize = storedSize > 0 ? storedSize : 13
        super.init()
    }

    var effectiveFont: NSFont {
        let size = fontSize * zoom
        if let f = NSFont(name: fontName, size: size) { return f }
        return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }

    var baseFont: NSFont {
        NSFont(name: fontName, size: fontSize)
            ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
    }

    func zoomIn()    { zoom += 0.1 }
    func zoomOut()   { zoom -= 0.1 }
    func resetZoom() { zoom = 1.0 }

    func openFontPanel() {
        let fm = NSFontManager.shared
        fm.target = self
        fm.setSelectedFont(baseFont, isMultiple: false)
        NSFontPanel.shared.orderFront(nil)
    }

    @objc func changeFont(_ sender: Any?) {
        guard let fm = sender as? NSFontManager else { return }
        let newFont = fm.convert(baseFont)
        fontName = newFont.fontName
        fontSize = newFont.pointSize
    }
}
