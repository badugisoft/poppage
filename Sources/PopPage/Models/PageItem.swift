import Foundation

enum IconType: String, Codable, CaseIterable, Hashable {
    case favicon
    case text
    case image

    var displayName: String {
        switch self {
        case .favicon: return L10n.tr("iconType.favicon", default: "Favicon")
        case .text: return L10n.tr("iconType.text", default: "Text")
        case .image: return L10n.tr("iconType.image", default: "Image")
        }
    }
}

enum NavigationPolicy: String, Codable, CaseIterable, Hashable {
    case block
    case openExternal
    case inPlace

    var displayName: String {
        switch self {
        case .block: return L10n.tr("navigationPolicy.block", default: "Do Not Navigate")
        case .openExternal: return L10n.tr("navigationPolicy.openExternal", default: "Open in External Browser")
        case .inPlace: return L10n.tr("navigationPolicy.inPlace", default: "Navigate in Popover")
        }
    }
}

struct HTTPHeader: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var value: String
    var isEnabled: Bool

    init(
        id: UUID = UUID(),
        name: String = "",
        value: String = "",
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.value = value
        self.isEnabled = isEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        value = try container.decodeIfPresent(String.self, forKey: .value) ?? ""
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
    }
}

struct PageItem: Codable, Identifiable, Hashable {
    var id: UUID
    var name: String
    var urlString: String
    var isEnabled: Bool

    var iconType: IconType
    var customText: String
    var customImageFileName: String?
    var imageIsTemplate: Bool

    var allowNewWindows: Bool
    var navigationPolicy: NavigationPolicy
    var customHeaders: [HTTPHeader]

    var width: Double
    var height: Double
    var resizable: Bool
    var rememberSize: Bool
    var savedWidth: Double?
    var savedHeight: Double?

    var toolbarOverlay: Bool
    var toolbarOverlayOpacity: Double
    var showZoomButtons: Bool
    var showReloadButton: Bool
    var showBackForwardButtons: Bool

    var defaultZoom: Double
    var rememberZoom: Bool
    var savedZoom: Double?

    var closeOnFocusLoss: Bool
    var animated: Bool
    var enableKeyboardShortcuts: Bool

    init(
        id: UUID = UUID(),
        name: String = L10n.tr("page.defaultName", default: "New Page"),
        urlString: String = "https://",
        isEnabled: Bool = true,
        iconType: IconType = .favicon,
        customText: String = "",
        customImageFileName: String? = nil,
        imageIsTemplate: Bool = false,
        allowNewWindows: Bool = true,
        navigationPolicy: NavigationPolicy = .inPlace,
        customHeaders: [HTTPHeader] = [],
        width: Double = 400,
        height: Double = 600,
        resizable: Bool = true,
        rememberSize: Bool = true,
        savedWidth: Double? = nil,
        savedHeight: Double? = nil,
        toolbarOverlay: Bool = false,
        toolbarOverlayOpacity: Double = 0.85,
        showZoomButtons: Bool = true,
        showReloadButton: Bool = true,
        showBackForwardButtons: Bool = true,
        defaultZoom: Double = 1.0,
        rememberZoom: Bool = true,
        savedZoom: Double? = nil,
        closeOnFocusLoss: Bool = true,
        animated: Bool = true,
        enableKeyboardShortcuts: Bool = true
    ) {
        self.id = id
        self.name = name
        self.urlString = urlString
        self.isEnabled = isEnabled
        self.iconType = iconType
        self.customText = customText
        self.customImageFileName = customImageFileName
        self.imageIsTemplate = imageIsTemplate
        self.allowNewWindows = allowNewWindows
        self.navigationPolicy = navigationPolicy
        self.customHeaders = customHeaders
        self.width = width
        self.height = height
        self.resizable = resizable
        self.rememberSize = rememberSize
        self.savedWidth = savedWidth
        self.savedHeight = savedHeight
        self.toolbarOverlay = toolbarOverlay
        self.toolbarOverlayOpacity = toolbarOverlayOpacity
        self.showZoomButtons = showZoomButtons
        self.showReloadButton = showReloadButton
        self.showBackForwardButtons = showBackForwardButtons
        self.defaultZoom = defaultZoom
        self.rememberZoom = rememberZoom
        self.savedZoom = savedZoom
        self.closeOnFocusLoss = closeOnFocusLoss
        self.animated = animated
        self.enableKeyboardShortcuts = enableKeyboardShortcuts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? L10n.tr("page.defaultName", default: "New Page")
        urlString = try container.decodeIfPresent(String.self, forKey: .urlString) ?? "https://"
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true

        iconType = try container.decodeIfPresent(IconType.self, forKey: .iconType) ?? .favicon
        customText = try container.decodeIfPresent(String.self, forKey: .customText) ?? ""
        customImageFileName = try container.decodeIfPresent(String.self, forKey: .customImageFileName)
        imageIsTemplate = try container.decodeIfPresent(Bool.self, forKey: .imageIsTemplate) ?? false

        allowNewWindows = try container.decodeIfPresent(Bool.self, forKey: .allowNewWindows) ?? true
        navigationPolicy = try container.decodeIfPresent(NavigationPolicy.self, forKey: .navigationPolicy) ?? .inPlace
        customHeaders = try container.decodeIfPresent([HTTPHeader].self, forKey: .customHeaders) ?? []

        width = try container.decodeIfPresent(Double.self, forKey: .width) ?? 400
        height = try container.decodeIfPresent(Double.self, forKey: .height) ?? 600
        resizable = try container.decodeIfPresent(Bool.self, forKey: .resizable) ?? true
        rememberSize = try container.decodeIfPresent(Bool.self, forKey: .rememberSize) ?? true
        savedWidth = try container.decodeIfPresent(Double.self, forKey: .savedWidth)
        savedHeight = try container.decodeIfPresent(Double.self, forKey: .savedHeight)

        toolbarOverlay = try container.decodeIfPresent(Bool.self, forKey: .toolbarOverlay) ?? false
        toolbarOverlayOpacity = try container.decodeIfPresent(Double.self, forKey: .toolbarOverlayOpacity) ?? 0.85
        showZoomButtons = try container.decodeIfPresent(Bool.self, forKey: .showZoomButtons) ?? true
        showReloadButton = try container.decodeIfPresent(Bool.self, forKey: .showReloadButton) ?? true
        showBackForwardButtons = try container.decodeIfPresent(Bool.self, forKey: .showBackForwardButtons) ?? true

        defaultZoom = try container.decodeIfPresent(Double.self, forKey: .defaultZoom) ?? 1.0
        rememberZoom = try container.decodeIfPresent(Bool.self, forKey: .rememberZoom) ?? true
        savedZoom = try container.decodeIfPresent(Double.self, forKey: .savedZoom)

        closeOnFocusLoss = try container.decodeIfPresent(Bool.self, forKey: .closeOnFocusLoss) ?? true
        animated = try container.decodeIfPresent(Bool.self, forKey: .animated) ?? true
        enableKeyboardShortcuts = try container.decodeIfPresent(Bool.self, forKey: .enableKeyboardShortcuts) ?? true
    }

    var effectiveHTTPHeaders: [(name: String, value: String)] {
        customHeaders.compactMap { header in
            guard header.isEnabled else { return nil }
            let trimmedName = header.name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedName.isEmpty else { return nil }
            return (trimmedName, header.value)
        }
    }

    var customUserAgentHeader: String? {
        effectiveHTTPHeaders.last { $0.name.caseInsensitiveCompare("user-agent") == .orderedSame }?.value
    }

    func makeURLRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        if let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            for header in effectiveHTTPHeaders {
                request.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        return request
    }

    var effectiveSize: (Double, Double) {
        if rememberSize, let savedWidth, let savedHeight {
            return (savedWidth, savedHeight)
        }
        return (width, height)
    }

    var effectiveZoom: Double {
        if rememberZoom, let savedZoom {
            return savedZoom
        }
        return defaultZoom
    }

    var normalizedURL: URL? {
        let trimmed = Self.normalizeURLString(urlString)
        guard !trimmed.isEmpty, trimmed != "https://", trimmed != "http://" else {
            return nil
        }
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host, !host.isEmpty else {
            return nil
        }
        return url
    }

    static func normalizeURLString(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        if trimmed.contains("://") {
            return trimmed
        }
        return "https://\(trimmed)"
    }
}
