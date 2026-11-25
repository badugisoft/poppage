import AppKit
import Foundation
import WebKit

@MainActor
final class PageStatusItem: NSObject, NSPopoverDelegate {
    private static let defaultUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"

    private(set) var page: PageItem

    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let webView: WKWebView
    private let coordinator: WebViewCoordinator
    private let contentVC: PopoverContentViewController

    private var lastLoadedURLString: String?
    private var lastFaviconURLString: String?
    private var lastCloseDate: Date?
    private var cachedFavicon: NSImage?

    var onWillOpen: ((UUID) -> Void)?
    var onOpenManager: (() -> Void)?
    var onSizeChanged: ((UUID, NSSize) -> Void)?
    var onZoomSaved: ((UUID, Double) -> Void)?

    var isPopoverShown: Bool {
        popover.isShown
    }

    init(page: PageItem) {
        self.page = page
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.customUserAgent = page.customUserAgentHeader ?? Self.defaultUserAgent

        self.coordinator = WebViewCoordinator(page: page)
        self.webView.navigationDelegate = coordinator
        self.webView.uiDelegate = coordinator

        self.contentVC = PopoverContentViewController(webView: webView, page: page)

        super.init()

        self.popover.contentViewController = contentVC
        self.popover.delegate = self
        self.contentVC.popover = popover

        self.contentVC.onResizeEnded = { [weak self] newSize in
            guard let self, self.page.rememberSize else { return }
            let adjustedHeight = self.page.toolbarOverlay
                ? newSize.height
                : max(200, newSize.height - PopoverContentViewController.toolbarHeight)
            self.onSizeChanged?(self.page.id, NSSize(width: newSize.width, height: adjustedHeight))
        }
        self.contentVC.onZoomChanged = { [weak self] newZoom in
            guard let self, self.page.rememberZoom else { return }
            self.onZoomSaved?(self.page.id, newZoom)
        }

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleStatusButtonClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        self.cachedFavicon = ImageStore.shared.loadFavicon(pageID: page.id)
        _ = self.contentVC.view
        self.contentVC.setZoom(page.effectiveZoom)
        apply(page: page)
    }

    private func contentSize(for page: PageItem) -> NSSize {
        let (w, h) = page.effectiveSize
        let totalHeight = h + (page.toolbarOverlay ? 0 : PopoverContentViewController.toolbarHeight)
        return NSSize(width: w, height: totalHeight)
    }

    func apply(page: PageItem) {
        let oldURL = self.page.normalizedURL?.absoluteString
        let overlayChanged = self.page.toolbarOverlay != page.toolbarOverlay
        self.page = page
        coordinator.page = page
        webView.customUserAgent = page.customUserAgentHeader ?? Self.defaultUserAgent

        popover.animates = page.animated
        popover.behavior = page.closeOnFocusLoss ? .transient : .applicationDefined
        if !popover.isShown || overlayChanged {
            popover.contentSize = contentSize(for: page)
        }
        contentVC.apply(page: page)

        let newURL = page.normalizedURL?.absoluteString
        if newURL != lastLoadedURLString {
            loadCurrentURL()
        }

        if page.iconType == .favicon {
            if cachedFavicon == nil || oldURL != newURL || lastFaviconURLString != newURL {
                refreshFaviconIfNeeded(force: oldURL != newURL)
            }
        }

        updateButtonAppearance()
    }

    func refreshFavicon() {
        refreshFaviconIfNeeded(force: true)
    }

    private func refreshFaviconIfNeeded(force: Bool) {
        guard let url = page.normalizedURL else { return }
        let urlKey = url.absoluteString
        if !force && cachedFavicon != nil && lastFaviconURLString == urlKey {
            return
        }
        lastFaviconURLString = urlKey

        Task { [weak self] in
            guard let self else { return }
            if let image = await FaviconFetcher.shared.fetchFavicon(
                for: url,
                pageID: self.page.id,
                headers: self.page.effectiveHTTPHeaders
            ) {
                self.cachedFavicon = image
                self.updateButtonAppearance()
            }
        }
    }

    private func loadCurrentURL() {
        if let url = page.normalizedURL {
            lastLoadedURLString = url.absoluteString
            webView.load(page.makeURLRequest(for: url))
        } else {
            lastLoadedURLString = nil
            let message = L10n.tr("webview.invalidURL", default: "Please set a valid URL.")
            webView.loadHTMLString(
                "<html><body style='font-family:-apple-system;display:flex;align-items:center;justify-content:center;height:100vh;color:#888;'>\(message)</body></html>",
                baseURL: nil
            )
        }
    }

    private func updateButtonAppearance() {
        guard let button = statusItem.button else { return }
        button.toolTip = page.name

        switch page.iconType {
        case .favicon:
            let baseImage = cachedFavicon
                ?? ImageStore.shared.loadFavicon(pageID: page.id)
                ?? NSImage(systemSymbolName: "globe", accessibilityDescription: page.name)
            if let baseImage {
                let isSymbolFallback = (cachedFavicon == nil && ImageStore.shared.loadFavicon(pageID: page.id) == nil)
                let resized = ImageStore.resizeForMenuBar(baseImage, maxHeight: 18, isTemplate: isSymbolFallback)
                button.image = resized
                button.imagePosition = .imageOnly
                button.title = ""
            } else {
                button.image = nil
                button.title = page.name
            }

        case .text:
            let label = page.customText.trimmingCharacters(in: .whitespacesAndNewlines)
            button.image = nil
            button.imagePosition = .noImage
            button.title = label.isEmpty ? page.name : label

        case .image:
            if let custom = ImageStore.shared.loadImage(fileName: page.customImageFileName) {
                button.image = ImageStore.resizeForMenuBar(custom, maxHeight: 18, isTemplate: page.imageIsTemplate)
                button.imagePosition = .imageOnly
                button.title = ""
            } else if let fallback = NSImage(systemSymbolName: "photo", accessibilityDescription: page.name) {
                button.image = ImageStore.resizeForMenuBar(fallback, maxHeight: 18, isTemplate: true)
                button.imagePosition = .imageOnly
                button.title = ""
            }
        }
    }

    @objc private func handleStatusButtonClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    func togglePopover() {
        if popover.isShown {
            closePopover()
            return
        }
        // Prevent reopening immediately if the .transient popover just closed via the status button click
        if let lastCloseDate, Date().timeIntervalSince(lastCloseDate) < 0.3 {
            return
        }
        openPopover()
    }

    func openPopover() {
        guard let button = statusItem.button else { return }
        onWillOpen?(page.id)
        popover.contentSize = contentSize(for: page)
        contentVC.setZoom(page.effectiveZoom)
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeFirstResponder(webView)
    }

    func closePopover() {
        if popover.isShown {
            popover.performClose(nil)
        }
    }

    private func showContextMenu() {
        guard let button = statusItem.button else { return }
        let menu = NSMenu()

        let openExternalItem = NSMenuItem(
            title: L10n.tr("context.openInBrowser", default: "Open in Browser"),
            action: #selector(menuOpenInBrowser),
            keyEquivalent: ""
        )
        openExternalItem.target = self
        menu.addItem(openExternalItem)

        let reloadItem = NSMenuItem(
            title: L10n.tr("context.reload", default: "Reload"),
            action: #selector(menuReload),
            keyEquivalent: ""
        )
        reloadItem.target = self
        menu.addItem(reloadItem)

        menu.addItem(.separator())

        let manageItem = NSMenuItem(
            title: L10n.tr("context.managePages", default: "Manage Pages…"),
            action: #selector(menuOpenManager),
            keyEquivalent: ""
        )
        manageItem.target = self
        menu.addItem(manageItem)

        let quitItem = NSMenuItem(
            title: L10n.tr("context.quit", default: "Quit PopPage"),
            action: #selector(menuQuit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func menuOpenInBrowser() {
        if let url = webView.url ?? page.normalizedURL {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func menuReload() {
        if let url = webView.url ?? page.normalizedURL,
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            webView.load(page.makeURLRequest(for: url))
        } else {
            webView.reload()
        }
    }

    @objc private func menuOpenManager() {
        onOpenManager?()
    }

    @objc private func menuQuit() {
        NSApp.terminate(nil)
    }

    func popoverDidClose(_ notification: Notification) {
        lastCloseDate = Date()
    }

    func invalidate() {
        popover.close()
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
