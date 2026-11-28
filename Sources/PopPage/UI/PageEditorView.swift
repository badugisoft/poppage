import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct PageEditorView: View {
    @Binding var page: PageItem
    var onDelete: () -> Void

    @ObservedObject private var l10n = LocalizationManager.shared
    @State private var isFetchingFavicon = false
    @State private var previewRefreshID = UUID()
    @State private var showDeleteConfirm = false
    @State private var showShortcutsPopover = false
    @State private var dataSelection = WebsiteDataSelection()
    @State private var showClearDataConfirm = false
    @State private var isClearingData = false
    @State private var dataClearMessage: String?
    @FocusState private var isURLFieldFocused: Bool

    var body: some View {
        Form {
            Section(L10n.tr("editor.section.general", default: "Basic Info")) {
                TextField(
                    L10n.tr("editor.name.label", default: "Name"),
                    text: $page.name,
                    prompt: Text(L10n.tr("editor.name.prompt", default: "e.g. GitHub"))
                )
                TextField(
                    L10n.tr("editor.url.label", default: "URL"),
                    text: $page.urlString,
                    prompt: Text(L10n.tr("editor.url.prompt", default: "https://example.com"))
                )
                .focused($isURLFieldFocused)
                .onSubmit {
                    normalizeURL()
                }
                .onChange(of: isURLFieldFocused) { _, focused in
                    if !focused {
                        normalizeURL()
                    }
                }

                if page.normalizedURL == nil {
                    Text(L10n.tr("editor.url.invalid", default: "Enter a valid URL starting with http:// or https://."))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }

                Toggle(L10n.tr("editor.enabled", default: "Show in Menu Bar"), isOn: $page.isEnabled)
            }

            Section(L10n.tr("editor.section.icon", default: "Menu Bar Icon")) {
                Picker(L10n.tr("editor.icon.style", default: "Style"), selection: $page.iconType) {
                    ForEach(IconType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Text(L10n.tr("editor.icon.preview", default: "Preview"))
                        .foregroundStyle(.secondary)
                    Spacer()
                    IconPreview(page: page, refreshTrigger: previewRefreshID)
                }

                switch page.iconType {
                case .favicon:
                    HStack {
                        Button {
                            refreshFavicon()
                        } label: {
                            if isFetchingFavicon {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text(L10n.tr("editor.icon.refreshFavicon", default: "Refresh Favicon"))
                            }
                        }
                        .disabled(isFetchingFavicon || page.normalizedURL == nil)

                        Spacer()
                    }

                case .text:
                    TextField(
                        L10n.tr("editor.icon.textLabel", default: "Display Text"),
                        text: $page.customText,
                        prompt: Text(L10n.tr("editor.icon.textPrompt", default: "Uses page name if empty"))
                    )

                case .image:
                    HStack {
                        Button(L10n.tr("editor.icon.chooseImage", default: "Choose Image…")) {
                            chooseCustomImage()
                        }
                        if page.customImageFileName != nil {
                            Button(L10n.tr("editor.icon.removeImage", default: "Remove"), role: .destructive) {
                                ImageStore.shared.removeImage(fileName: page.customImageFileName)
                                page.customImageFileName = nil
                                previewRefreshID = UUID()
                            }
                        }
                        Spacer()
                    }
                    Toggle(L10n.tr("editor.icon.template", default: "Use Template Image"), isOn: $page.imageIsTemplate)
                    Text(L10n.tr("editor.icon.templateHelp", default: "Automatically inverts icon colors for dark mode."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(L10n.tr("editor.section.popover", default: "Popover Window")) {
                Toggle(L10n.tr("editor.closeOnFocusLoss", default: "Close automatically when focus is lost"), isOn: $page.closeOnFocusLoss)
                Toggle(L10n.tr("editor.animated", default: "Open/Close Animation"), isOn: $page.animated)
                Toggle(isOn: $page.enableKeyboardShortcuts) {
                    HStack(spacing: 5) {
                        Text(L10n.tr("settings.shortcuts.enable", default: "Enable Keyboard Shortcuts"))
                        Button {
                            showShortcutsPopover.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                        .help(L10n.tr("settings.section.shortcuts", default: "Keyboard Shortcuts"))
                        .popover(isPresented: $showShortcutsPopover, arrowEdge: .trailing) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(L10n.tr("settings.section.shortcuts", default: "Keyboard Shortcuts"))
                                    .font(.headline)
                                Divider()
                                shortcutRow(L10n.tr("settings.shortcuts.zoomIn", default: "Zoom In"), keys: "⌘ +")
                                shortcutRow(L10n.tr("settings.shortcuts.zoomOut", default: "Zoom Out"), keys: "⌘ -")
                                shortcutRow(L10n.tr("settings.shortcuts.zoomReset", default: "Reset Zoom"), keys: "⌘ 0")
                                shortcutRow(L10n.tr("settings.shortcuts.back", default: "Back"), keys: "⌘ [")
                                shortcutRow(L10n.tr("settings.shortcuts.forward", default: "Forward"), keys: "⌘ ]")
                                shortcutRow(L10n.tr("settings.shortcuts.reload", default: "Reload"), keys: "⌘ R")
                            }
                            .padding(12)
                            .frame(width: 220)
                        }
                    }
                }

                HStack {
                    Text(L10n.tr("editor.defaultWidth", default: "Default Width"))
                    Spacer()
                    TextField("", value: $page.width, format: .number)
                        .frame(width: 72)
                        .multilineTextAlignment(.trailing)
                    Text(L10n.tr("editor.unit.pt", default: "pt"))
                        .foregroundStyle(.secondary)
                    Stepper("", value: $page.width, in: 250...1600, step: 20)
                        .labelsHidden()
                }

                HStack {
                    Text(L10n.tr("editor.defaultHeight", default: "Default Height"))
                    Spacer()
                    TextField("", value: $page.height, format: .number)
                        .frame(width: 72)
                        .multilineTextAlignment(.trailing)
                    Text(L10n.tr("editor.unit.pt", default: "pt"))
                        .foregroundStyle(.secondary)
                    Stepper("", value: $page.height, in: 200...1200, step: 20)
                        .labelsHidden()
                }

                Text(
                    page.toolbarOverlay
                        ? L10n.tr("editor.size.captionOverlay", default: "Total size including the toolbar.")
                        : L10n.tr("editor.size.captionContent", default: "Webpage area size excluding the toolbar.")
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Toggle(L10n.tr("editor.resizable", default: "Allow Resizing"), isOn: $page.resizable)

                Toggle(L10n.tr("editor.rememberSize", default: "Remember Modified Size"), isOn: $page.rememberSize)
                    .disabled(!page.resizable)

                if let savedW = page.savedWidth, let savedH = page.savedHeight {
                    HStack {
                        Text(L10n.format("editor.savedSize", default: "Saved Size: %d × %d", Int(round(savedW)), Int(round(savedH))))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(L10n.tr("editor.reset", default: "Reset")) {
                            page.savedWidth = nil
                            page.savedHeight = nil
                        }
                        .font(.caption)
                    }
                }

                HStack {
                    Text(L10n.tr("editor.defaultZoom", default: "Default Zoom"))
                    Spacer()
                    Text("\(Int(round(page.defaultZoom * 100)))%")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    Stepper("", value: $page.defaultZoom, in: 0.5...3.0, step: 0.1)
                        .labelsHidden()
                }

                Toggle(L10n.tr("editor.rememberZoom", default: "Remember Modified Zoom"), isOn: $page.rememberZoom)

                if let savedZoom = page.savedZoom {
                    HStack {
                        Text(L10n.format("editor.savedZoom", default: "Saved Zoom: %d%%", Int(round(savedZoom * 100))))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button(L10n.tr("editor.reset", default: "Reset")) {
                            page.savedZoom = nil
                        }
                        .font(.caption)
                    }
                }
            }

            Section(L10n.tr("editor.section.navigation", default: "Links & Navigation")) {
                Toggle(L10n.tr("editor.allowNewWindows", default: "Open new window links in external browser"), isOn: $page.allowNewWindows)

                Picker(L10n.tr("editor.navigationPolicy", default: "Page Navigation"), selection: $page.navigationPolicy) {
                    ForEach(NavigationPolicy.allCases, id: \.self) { policy in
                        Text(policy.displayName).tag(policy)
                    }
                }
            }

            Section(L10n.tr("editor.section.headers", default: "HTTP Headers")) {
                ForEach($page.customHeaders) { $header in
                    HStack(spacing: 8) {
                        Toggle("", isOn: $header.isEnabled)
                            .labelsHidden()
                            .toggleStyle(.checkbox)

                        TextField(
                            "",
                            text: $header.name,
                            prompt: Text(L10n.tr("editor.headers.namePrompt", default: "Header Name"))
                        )
                        .frame(minWidth: 110, idealWidth: 140)

                        TextField(
                            "",
                            text: $header.value,
                            prompt: Text(L10n.tr("editor.headers.valuePrompt", default: "Value"))
                        )

                        Button {
                            let targetID = header.id
                            page.customHeaders.removeAll { $0.id == targetID }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.borderless)
                        .help(L10n.tr("editor.headers.removeHelp", default: "Remove Header"))
                    }
                }

                Button(L10n.tr("editor.headers.add", default: "Add Header")) {
                    page.customHeaders.append(HTTPHeader())
                }

                Text(L10n.tr("editor.headers.caption", default: "Sent on HTTP/HTTPS requests for this page. Changes apply on next load or reload."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section(L10n.tr("editor.section.toolbar", default: "Bottom Toolbar")) {
                Toggle(L10n.tr("editor.toolbar.overlay", default: "Overlay on Webpage"), isOn: $page.toolbarOverlay)
                if page.toolbarOverlay {
                    HStack {
                        Text(L10n.tr("editor.toolbar.opacity", default: "Background Opacity"))
                        Slider(value: $page.toolbarOverlayOpacity, in: 0.0...1.0, step: 0.05)
                        Text("\(Int(round(page.toolbarOverlayOpacity * 100)))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
                Toggle(L10n.tr("editor.toolbar.backForward", default: "Back/Forward Buttons"), isOn: $page.showBackForwardButtons)
                Toggle(L10n.tr("editor.toolbar.reload", default: "Reload Button"), isOn: $page.showReloadButton)
                Toggle(L10n.tr("editor.toolbar.zoom", default: "Zoom Buttons"), isOn: $page.showZoomButtons)
            }

            Section(L10n.tr("editor.section.websiteData", default: "Website Data")) {
                WebsiteDataSelectionToggles(selection: $dataSelection)

                HStack {
                    Button(L10n.tr("editor.websiteData.clear", default: "Clear Website Data…"), role: .destructive) {
                        showClearDataConfirm = true
                    }
                    .disabled(dataSelection.isEmpty || page.normalizedURL == nil || isClearingData)

                    if isClearingData {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Spacer()
                }

                Text(L10n.tr("editor.websiteData.caption", default: "Clears selected data for this page's domain and reloads it. Shared domains may affect other pages."))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let dataClearMessage {
                    Text(dataClearMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                HStack {
                    Button(L10n.tr("editor.openPopover", default: "Open Popover")) {
                        StatusBarManager.shared.openPopover(for: page.id)
                    }
                    .disabled(!page.isEnabled || page.normalizedURL == nil)

                    Spacer()

                    Button(L10n.tr("editor.deletePage", default: "Delete Page"), role: .destructive) {
                        showDeleteConfirm = true
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onChange(of: page.width) { _, _ in
            page.savedWidth = nil
            page.savedHeight = nil
        }
        .onChange(of: page.height) { _, _ in
            page.savedWidth = nil
            page.savedHeight = nil
        }
        .onChange(of: page.toolbarOverlay) { _, _ in
            page.savedWidth = nil
            page.savedHeight = nil
        }
        .onChange(of: page.defaultZoom) { _, newValue in
            let rounded = (newValue * 10).rounded() / 10
            if rounded != newValue {
                page.defaultZoom = rounded
            }
            page.savedZoom = nil
        }
        .alert(L10n.tr("editor.deleteAlert.title", default: "Delete this page?"), isPresented: $showDeleteConfirm) {
            Button(L10n.tr("editor.deleteAlert.cancel", default: "Cancel"), role: .cancel) {}
            Button(L10n.tr("editor.deleteAlert.confirm", default: "Delete"), role: .destructive) {
                onDelete()
            }
        } message: {
            Text(L10n.format("editor.deleteAlert.message", default: "Settings and saved icon for '%@' will be deleted.", page.name))
        }
        .alert(L10n.tr("editor.websiteData.alert.title", default: "Clear Website Data?"), isPresented: $showClearDataConfirm) {
            Button(L10n.tr("editor.websiteData.alert.cancel", default: "Cancel"), role: .cancel) {}
            Button(L10n.tr("editor.websiteData.alert.confirm", default: "Clear"), role: .destructive) {
                clearWebsiteData()
            }
        } message: {
            let target = page.normalizedURL?.host ?? page.name
            Text(L10n.format("editor.websiteData.alert.message", default: "Selected website data for '%@' will be deleted and the page will reload.", target))
        }
    }

    @ViewBuilder
    private func shortcutRow(_ title: String, keys: String) -> some View {
        HStack {
            Text(title)
                .font(.callout)
            Spacer()
            Text(keys)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 4))
        }
    }

    private func normalizeURL() {
        let normalized = PageItem.normalizeURLString(page.urlString)
        if normalized != page.urlString {
            page.urlString = normalized
        }
    }

    private func refreshFavicon() {
        guard let url = page.normalizedURL else { return }
        isFetchingFavicon = true
        let pageID = page.id
        let headers = page.effectiveHTTPHeaders
        Task {
            _ = await FaviconFetcher.shared.fetchFavicon(for: url, pageID: pageID, headers: headers)
            StatusBarManager.shared.refreshFavicon(for: pageID)
            previewRefreshID = UUID()
            isFetchingFavicon = false
        }
    }

    private func clearWebsiteData() {
        guard let url = page.normalizedURL, !dataSelection.isEmpty else { return }
        isClearingData = true
        dataClearMessage = nil
        let selection = dataSelection
        let pageID = page.id
        Task {
            await WebsiteDataService.clearData(for: url, selection: selection)
            StatusBarManager.shared.reload(for: pageID)
            isClearingData = false
            dataClearMessage = L10n.tr("websiteData.cleared", default: "Selected website data cleared.")
        }
    }

    private func chooseCustomImage() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .icns, .pdf]

        if panel.runModal() == .OK, let url = panel.url {
            if let savedName = ImageStore.shared.saveCustomImage(from: url, pageID: page.id) {
                page.customImageFileName = savedName
                previewRefreshID = UUID()
            }
        }
    }
}
