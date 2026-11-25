import Foundation
import SwiftUI

extension Notification.Name {
    static let appLanguageDidChange = Notification.Name("PopPageAppLanguageDidChange")
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case en
    case ko
    case zhHans = "zh-Hans"
    case ja
    case es
    case de
    case fr
    case tlh

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return L10n.tr("settings.language.system", default: "System Default")
        case .en:
            return "English"
        case .ko:
            return "한국어"
        case .zhHans:
            return "简体中文"
        case .ja:
            return "日本語"
        case .es:
            return "Español"
        case .de:
            return "Deutsch"
        case .fr:
            return "Français"
        case .tlh:
            return "tlhIngan Hol"
        }
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: AppLanguage {
        didSet {
            guard oldValue != language else { return }
            UserDefaults.standard.set(language.rawValue, forKey: L10n.defaultsKey)
            L10n.setLanguage(language)
            NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
        }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: L10n.defaultsKey) ?? AppLanguage.system.rawValue
        let initial = AppLanguage(rawValue: raw) ?? .system
        self.language = initial
        L10n.setLanguage(initial)
    }
}

enum L10n {
    fileprivate static let defaultsKey = "appLanguage"
    private static let lock = NSLock()
    private nonisolated(unsafe) static var activeBundle: Bundle = resolveInitialBundle()

    private static func resolveInitialBundle() -> Bundle {
        let raw = UserDefaults.standard.string(forKey: defaultsKey) ?? AppLanguage.system.rawValue
        let language = AppLanguage(rawValue: raw) ?? .system
        return bundle(for: language)
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        switch language {
        case .system:
            return .main
        default:
            if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
            return .main
        }
    }

    static func setLanguage(_ language: AppLanguage) {
        let next = bundle(for: language)
        lock.lock()
        activeBundle = next
        lock.unlock()
    }

    static func tr(_ key: String, default defaultValue: String? = nil) -> String {
        lock.lock()
        let bundle = activeBundle
        lock.unlock()
        return bundle.localizedString(forKey: key, value: defaultValue, table: "Localizable")
    }

    static func format(_ key: String, default defaultValue: String? = nil, _ args: CVarArg...) -> String {
        let pattern = tr(key, default: defaultValue)
        return String(format: pattern, locale: Locale.current, arguments: args)
    }
}
