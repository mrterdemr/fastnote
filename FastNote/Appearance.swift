import AppKit

enum LanguageMode: String, CaseIterable, Identifiable {
    case system
    case en
    case tr
    case zhHans = "zh-Hans"
    case es
    case fr
    case de
    case ja
    case pt
    case ru
    case it
    case ko
    case nl
    case pl

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return NSLocalizedString("System", comment: "")
        case .en:     return "English"
        case .tr:     return "Türkçe"
        case .zhHans: return "中文（简体）"
        case .es:     return "Español"
        case .fr:     return "Français"
        case .de:     return "Deutsch"
        case .ja:     return "日本語"
        case .pt:     return "Português"
        case .ru:     return "Русский"
        case .it:     return "Italiano"
        case .ko:     return "한국어"
        case .nl:     return "Nederlands"
        case .pl:     return "Polski"
        }
    }

    static let storageKey = "AppLanguage"

    static var current: LanguageMode {
        let raw = UserDefaults.standard.string(forKey: storageKey)
        return raw.flatMap(LanguageMode.init) ?? .system
    }

    func apply() {
        if self == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([rawValue], forKey: "AppleLanguages")
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var label: String {
        switch self {
        case .light: return NSLocalizedString("Light", comment: "")
        case .dark: return NSLocalizedString("Dark", comment: "")
        case .system: return NSLocalizedString("System", comment: "")
        }
    }

    var nsAppearance: NSAppearance? {
        switch self {
        case .light: return NSAppearance(named: .aqua)
        case .dark: return NSAppearance(named: .darkAqua)
        case .system: return nil
        }
    }

    static let storageKey = "appearanceMode"

    static var current: AppearanceMode {
        let raw = UserDefaults.standard.string(forKey: storageKey)
        return raw.flatMap(AppearanceMode.init) ?? .system
    }

    func apply() {
        NSApp.appearance = nsAppearance
    }
}
