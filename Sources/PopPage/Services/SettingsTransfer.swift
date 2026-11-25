import Foundation

struct SettingsBackup: Codable {
    var version: Int
    var exportedAt: Date
    var appLanguage: String?
    var pages: [PageItem]
    var customIcons: [String: Data]?

    init(
        version: Int = 1,
        exportedAt: Date = Date(),
        appLanguage: String? = nil,
        pages: [PageItem],
        customIcons: [String: Data]? = nil
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.appLanguage = appLanguage
        self.pages = pages
        self.customIcons = customIcons
    }
}

enum SettingsTransferError: LocalizedError {
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return L10n.tr("settings.import.invalidFormat", default: "The selected file is not a valid PopPage settings backup.")
        }
    }
}

@MainActor
enum SettingsTransfer {
    static func makeBackup(
        pages: [PageItem],
        language: AppLanguage
    ) -> SettingsBackup {
        var icons: [String: Data] = [:]
        for page in pages {
            if let fileName = page.customImageFileName, !fileName.isEmpty {
                let url = ImageStore.shared.fileURL(for: fileName)
                if let data = try? Data(contentsOf: url) {
                    icons[fileName] = data
                }
            }
        }
        return SettingsBackup(
            version: 1,
            exportedAt: Date(),
            appLanguage: language.rawValue,
            pages: pages,
            customIcons: icons.isEmpty ? nil : icons
        )
    }

    static func exportBackup(_ backup: SettingsBackup, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(backup)
        try data.write(to: url, options: .atomic)
    }

    static func readBackup(from url: URL) throws -> SettingsBackup {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let backup = try? decoder.decode(SettingsBackup.self, from: data) {
            return backup
        }
        if let pages = try? decoder.decode([PageItem].self, from: data) {
            return SettingsBackup(version: 1, exportedAt: Date(), appLanguage: nil, pages: pages, customIcons: nil)
        }
        throw SettingsTransferError.invalidFormat
    }

    static func applyBackup(_ backup: SettingsBackup) {
        for (rawName, data) in backup.customIcons ?? [:] {
            let safeName = (rawName as NSString).lastPathComponent
            guard !safeName.isEmpty else { continue }
            let destURL = ImageStore.shared.fileURL(for: safeName)
            try? data.write(to: destURL, options: .atomic)
        }

        PageStore.shared.pages = backup.pages

        if let langRaw = backup.appLanguage, let lang = AppLanguage(rawValue: langRaw) {
            LocalizationManager.shared.language = lang
        }
    }
}
