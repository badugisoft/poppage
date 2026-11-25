import AppKit
import Foundation
import WebKit

@MainActor
final class PopoverContentViewController: NSViewController {
    static let toolbarHeight: CGFloat = 31

    let webView: WKWebView
    weak var popover: NSPopover?
    var onResizeEnded: ((NSSize) -> Void)?
    var onZoomChanged: ((Double) -> Void)?

    private var page: PageItem

    private let toolbarContainer = NSView()
    private let toolbarStack = NSStackView()
    private let separator = NSBox()
    private let backButton = NSButton()
    private let forwardButton = NSButton()
    private let reloadButton = NSButton()
    private let zoomOutButton = NSButton()
    private let zoomResetButton = NSButton()
    private let zoomInButton = NSButton()
    private let openExternalButton = NSButton()
    private let resizeGrip = ResizeGripView()

    private var webViewBottomToToolbar: NSLayoutConstraint?
    private var webViewBottomToView: NSLayoutConstraint?

    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?
    private var themeColorObservation: NSKeyValueObservation?
    private var underPageBackgroundColorObservation: NSKeyValueObservation?
    private nonisolated(unsafe) var languageObserver: NSObjectProtocol?
    private nonisolated(unsafe) var keyDownMonitor: Any?

    deinit {
        if let languageObserver {
            NotificationCenter.default.removeObserver(languageObserver)
        }
        if let keyDownMonitor {
            NSEvent.removeMonitor(keyDownMonitor)
        }
    }

    init(webView: WKWebView, page: PageItem) {
        self.webView = webView
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let (w, h) = page.effectiveSize
        let totalHeight = h + (page.toolbarOverlay ? 0 : Self.toolbarHeight)
        let root = NSView(frame: NSRect(x: 0, y: 0, width: w, height: totalHeight))
        root.wantsLayer = true
        self.view = root
        setupUI()
        setupObservations()
        apply(page: page)
    }

    private func setupUI() {
        toolbarContainer.wantsLayer = true
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false

        toolbarStack.orientation = .horizontal
        toolbarStack.alignment = .centerY
        toolbarStack.spacing = 4
        toolbarStack.edgeInsets = NSEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        toolbarStack.translatesAutoresizingMaskIntoConstraints = false

        configureSymbolButton(backButton, symbol: "chevron.left", tooltip: L10n.tr("toolbar.back", default: "Back"), action: #selector(goBack))
        configureSymbolButton(forwardButton, symbol: "chevron.right", tooltip: L10n.tr("toolbar.forward", default: "Forward"), action: #selector(goForward))
        configureSymbolButton(reloadButton, symbol: "arrow.clockwise", tooltip: L10n.tr("toolbar.reload", default: "Reload"), action: #selector(reloadPage))
        configureSymbolButton(zoomOutButton, symbol: "minus.magnifyingglass", tooltip: L10n.tr("toolbar.zoomOut", default: "Zoom Out"), action: #selector(zoomOut))

        zoomResetButton.bezelStyle = .recessed
        zoomResetButton.isBordered = false
        zoomResetButton.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        zoomResetButton.title = "100%"
        zoomResetButton.toolTip = L10n.tr("toolbar.zoomReset", default: "Reset to Default Zoom")
        zoomResetButton.target = self
        zoomResetButton.action = #selector(zoomReset)

        configureSymbolButton(zoomInButton, symbol: "plus.magnifyingglass", tooltip: L10n.tr("toolbar.zoomIn", default: "Zoom In"), action: #selector(zoomIn))
        configureSymbolButton(openExternalButton, symbol: "safari", tooltip: L10n.tr("toolbar.openInBrowser", default: "Open in Default Browser"), action: #selector(openInExternalBrowser))

        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        toolbarStack.addArrangedSubview(backButton)
        toolbarStack.addArrangedSubview(forwardButton)
        toolbarStack.addArrangedSubview(reloadButton)
        toolbarStack.addArrangedSubview(zoomOutButton)
        toolbarStack.addArrangedSubview(zoomResetButton)
        toolbarStack.addArrangedSubview(zoomInButton)
        toolbarStack.addArrangedSubview(spacer)
        toolbarStack.addArrangedSubview(openExternalButton)
        toolbarStack.addArrangedSubview(resizeGrip)

        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        webView.translatesAutoresizingMaskIntoConstraints = false

        resizeGrip.translatesAutoresizingMaskIntoConstraints = false
        resizeGrip.onDrag = { [weak self] deltaX, deltaY, startSize in
            guard let self, let popover = self.popover else { return }
            let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1200, height: 800)
            let newWidth = min(max(250, startSize.width + deltaX * 2), screenFrame.width - 40)
            let newHeight = min(max(200, startSize.height - deltaY), screenFrame.height - 60)
            popover.contentSize = NSSize(width: round(newWidth), height: round(newHeight))
        }
        resizeGrip.onDragEnd = { [weak self] in
            guard let self, let popover = self.popover else { return }
            self.onResizeEnded?(popover.contentSize)
        }
        resizeGrip.sizeProvider = { [weak self] in
            self?.popover?.contentSize ?? NSSize(width: self?.page.width ?? 400, height: self?.page.height ?? 600)
        }

        toolbarContainer.addSubview(separator)
        toolbarContainer.addSubview(toolbarStack)

        view.addSubview(webView)
        view.addSubview(toolbarContainer)

        let bottomToToolbar = webView.bottomAnchor.constraint(equalTo: toolbarContainer.topAnchor)
        let bottomToView = webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        webViewBottomToToolbar = bottomToToolbar
        webViewBottomToView = bottomToView

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            toolbarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            separator.topAnchor.constraint(equalTo: toolbarContainer.topAnchor),
            separator.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor),

            toolbarStack.topAnchor.constraint(equalTo: separator.bottomAnchor),
            toolbarStack.leadingAnchor.constraint(equalTo: toolbarContainer.leadingAnchor),
            toolbarStack.trailingAnchor.constraint(equalTo: toolbarContainer.trailingAnchor),
            toolbarStack.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor),
            toolbarStack.heightAnchor.constraint(equalToConstant: 30),

            resizeGrip.widthAnchor.constraint(equalToConstant: 16),
            resizeGrip.heightAnchor.constraint(equalToConstant: 16),
        ])
    }

    private func configureSymbolButton(_ button: NSButton, symbol: String, tooltip: String, action: Selector) {
        button.bezelStyle = .recessed
        button.isBordered = false
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: tooltip)
        button.imagePosition = .imageOnly
        button.toolTip = tooltip
        button.target = self
        button.action = action
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    private func setupObservations() {
        canGoBackObservation = webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] webView, _ in
            Task { @MainActor in
                self?.backButton.isEnabled = webView.canGoBack
            }
        }
        canGoForwardObservation = webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] webView, _ in
            Task { @MainActor in
                self?.forwardButton.isEnabled = webView.canGoForward
            }
        }
        themeColorObservation = webView.observe(\.themeColor, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor in
                self?.updateToolbarColors()
            }
        }
        underPageBackgroundColorObservation = webView.observe(\.underPageBackgroundColor, options: [.initial, .new]) { [weak self] _, _ in
            Task { @MainActor in
                self?.updateToolbarColors()
            }
        }
        languageObserver = NotificationCenter.default.addObserver(
            forName: .appLanguageDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateLocalizedStrings()
            }
        }
        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let handled = MainActor.assumeIsolated {
                self?.handleKeyDown(event) == nil
            }
            return handled ? nil : event
        }
    }

    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        guard page.enableKeyboardShortcuts,
              popover?.isShown == true,
              event.window === view.window else {
            return event
        }

        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard flags.contains(.command),
              !flags.contains(.control),
              !flags.contains(.option) else {
            return event
        }

        let key = event.charactersIgnoringModifiers?.lowercased() ?? ""
        switch key {
        case "=", "+":
            zoomIn()
            return nil
        case "-":
            guard !flags.contains(.shift) else { return event }
            zoomOut()
            return nil
        case "0":
            guard !flags.contains(.shift) else { return event }
            zoomReset()
            return nil
        case "[":
            guard !flags.contains(.shift) else { return event }
            if webView.canGoBack {
                goBack()
            }
            return nil
        case "]":
            guard !flags.contains(.shift) else { return event }
            if webView.canGoForward {
                goForward()
            }
            return nil
        case "r":
            guard !flags.contains(.shift) else { return event }
            reloadPage()
            return nil
        default:
            return event
        }
    }

    private func updateLocalizedStrings() {
        let backTip = L10n.tr("toolbar.back", default: "Back")
        backButton.toolTip = backTip
        backButton.image?.accessibilityDescription = backTip

        let forwardTip = L10n.tr("toolbar.forward", default: "Forward")
        forwardButton.toolTip = forwardTip
        forwardButton.image?.accessibilityDescription = forwardTip

        let reloadTip = L10n.tr("toolbar.reload", default: "Reload")
        reloadButton.toolTip = reloadTip
        reloadButton.image?.accessibilityDescription = reloadTip

        let zoomOutTip = L10n.tr("toolbar.zoomOut", default: "Zoom Out")
        zoomOutButton.toolTip = zoomOutTip
        zoomOutButton.image?.accessibilityDescription = zoomOutTip

        zoomResetButton.toolTip = L10n.tr("toolbar.zoomReset", default: "Reset to Default Zoom")

        let zoomInTip = L10n.tr("toolbar.zoomIn", default: "Zoom In")
        zoomInButton.toolTip = zoomInTip
        zoomInButton.image?.accessibilityDescription = zoomInTip

        let browserTip = L10n.tr("toolbar.openInBrowser", default: "Open in Default Browser")
        openExternalButton.toolTip = browserTip
        openExternalButton.image?.accessibilityDescription = browserTip
    }

    func apply(page: PageItem) {
        let defaultZoomChanged = self.page.defaultZoom != page.defaultZoom
        self.page = page
        backButton.isHidden = !page.showBackForwardButtons
        forwardButton.isHidden = !page.showBackForwardButtons
        reloadButton.isHidden = !page.showReloadButton
        zoomOutButton.isHidden = !page.showZoomButtons
        zoomResetButton.isHidden = !page.showZoomButtons
        zoomInButton.isHidden = !page.showZoomButtons
        resizeGrip.isHidden = !page.resizable
        separator.isHidden = page.toolbarOverlay

        if page.toolbarOverlay {
            webViewBottomToToolbar?.isActive = false
            webViewBottomToView?.isActive = true
        } else {
            webViewBottomToView?.isActive = false
            webViewBottomToToolbar?.isActive = true
        }

        if defaultZoomChanged {
            setZoom(page.defaultZoom)
        } else {
            updateZoomLabel()
        }
        updateToolbarColors()
    }

    func setZoom(_ zoom: Double) {
        webView.pageZoom = min(max(0.5, zoom), 3.0)
        updateZoomLabel()
    }

    private func updateToolbarColors() {
        let baseColor = webView.themeColor ?? webView.underPageBackgroundColor ?? NSColor.windowBackgroundColor
        let alpha: CGFloat = page.toolbarOverlay ? CGFloat(min(max(0.0, page.toolbarOverlayOpacity), 1.0)) : 1.0
        toolbarContainer.layer?.backgroundColor = baseColor.withAlphaComponent(alpha).cgColor

        if let srgb = baseColor.usingColorSpace(.sRGB) {
            let luminance = 0.299 * srgb.redComponent + 0.587 * srgb.greenComponent + 0.114 * srgb.blueComponent
            toolbarContainer.appearance = NSAppearance(named: luminance < 0.5 ? .darkAqua : .aqua)
        } else {
            toolbarContainer.appearance = nil
        }
    }

    private func updateZoomLabel() {
        let percent = Int(round(webView.pageZoom * 100))
        zoomResetButton.title = "\(percent)%"
    }

    @objc private func goBack() {
        webView.goBack()
    }

    @objc private func goForward() {
        webView.goForward()
    }

    @objc private func reloadPage() {
        if let url = webView.url ?? page.normalizedURL,
           let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https" {
            webView.load(page.makeURLRequest(for: url))
        } else {
            webView.reload()
        }
    }

    @objc private func zoomOut() {
        let next = max(0.5, round((webView.pageZoom - 0.1) * 10) / 10)
        setZoom(next)
        onZoomChanged?(webView.pageZoom)
    }

    @objc private func zoomReset() {
        setZoom(page.defaultZoom)
        onZoomChanged?(webView.pageZoom)
    }

    @objc private func zoomIn() {
        let next = min(3.0, round((webView.pageZoom + 0.1) * 10) / 10)
        setZoom(next)
        onZoomChanged?(webView.pageZoom)
    }

    @objc private func openInExternalBrowser() {
        if let url = webView.url ?? page.normalizedURL {
            NSWorkspace.shared.open(url)
        }
    }
}

@MainActor
private final class ResizeGripView: NSView {
    var sizeProvider: (() -> NSSize)?
    var onDrag: ((CGFloat, CGFloat, NSSize) -> Void)?
    var onDragEnd: (() -> Void)?

    private var dragStartMouseLocation: NSPoint = .zero
    private var dragStartSize: NSSize = .zero

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.tertiaryLabelColor.setStroke()
        let path = NSBezierPath()
        path.lineWidth = 1.2
        for offset in stride(from: 4.0, through: 12.0, by: 4.0) {
            path.move(to: NSPoint(x: bounds.maxX - offset, y: bounds.minY + 2))
            path.line(to: NSPoint(x: bounds.maxX - 2, y: bounds.minY + offset))
        }
        path.stroke()
    }

    override func mouseDown(with event: NSEvent) {
        dragStartMouseLocation = NSEvent.mouseLocation
        dragStartSize = sizeProvider?() ?? NSSize(width: 400, height: 600)
    }

    override func mouseDragged(with event: NSEvent) {
        let current = NSEvent.mouseLocation
        let dx = current.x - dragStartMouseLocation.x
        let dy = current.y - dragStartMouseLocation.y
        onDrag?(dx, dy, dragStartSize)
    }

    override func mouseUp(with event: NSEvent) {
        onDragEnd?()
    }
}
