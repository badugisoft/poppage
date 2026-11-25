import SwiftUI

struct ManagerView: View {
    @ObservedObject private var store = PageStore.shared
    @ObservedObject private var l10n = LocalizationManager.shared
    @State private var selectedPageID: UUID?
    @State private var showSettings: Bool

    init(initialSelectedPageID: UUID? = nil, initialShowSettings: Bool = false) {
        _selectedPageID = State(initialValue: initialSelectedPageID)
        _showSettings = State(initialValue: initialShowSettings)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedPageID) {
                    ForEach($store.pages) { $page in
                        HStack(spacing: 8) {
                            IconPreview(page: page)
                                .frame(width: 22, height: 22)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(page.name.isEmpty ? L10n.tr("manager.untitled", default: "Untitled") : page.name)
                                    .lineLimit(1)
                                Text(page.urlString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }

                            Spacer(minLength: 4)

                            Toggle("", isOn: $page.isEnabled)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .controlSize(.mini)
                                .help(L10n.tr("manager.enableHelp", default: "Show in Menu Bar"))
                        }
                        .padding(.vertical, 2)
                        .tag(page.id)
                    }
                    .onMove(perform: store.move)
                }
                .listStyle(.sidebar)

                Divider()

                HStack(spacing: 8) {
                    Button {
                        let newPage = store.addNewPage()
                        showSettings = false
                        selectedPageID = newPage.id
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.borderless)
                    .help(L10n.tr("manager.addHelp", default: "Add New Page"))

                    Button {
                        if let id = selectedPageID {
                            deletePage(id: id)
                        }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.borderless)
                    .disabled(selectedPageID == nil)
                    .help(L10n.tr("manager.deleteHelp", default: "Delete Selected Page"))

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)

                Divider()

                Button {
                    showSettings = true
                    selectedPageID = nil
                } label: {
                    HStack {
                        Label(L10n.tr("manager.settings", default: "Settings"), systemImage: "gearshape")
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        showSettings
                            ? Color.accentColor.opacity(0.18)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 6)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 320)
        } detail: {
            if showSettings {
                AppSettingsView()
            } else if let selectedID = selectedPageID,
               let index = store.pages.firstIndex(where: { $0.id == selectedID }) {
                PageEditorView(
                    page: $store.pages[index],
                    onDelete: {
                        deletePage(id: selectedID)
                    }
                )
                .id(selectedID)
            } else {
                ContentUnavailableView(
                    L10n.tr("manager.emptyTitle", default: "Select a Page"),
                    systemImage: "menubar.rectangle",
                    description: Text(L10n.tr("manager.emptyDescription", default: "Click the + button at the bottom left to add a website to the menu bar."))
                )
            }
        }
        .onChange(of: selectedPageID) { _, newValue in
            if newValue != nil {
                showSettings = false
            }
        }
        .onAppear {
            if selectedPageID == nil && !showSettings {
                selectedPageID = store.pages.first?.id
            }
        }
    }

    private func deletePage(id: UUID) {
        let currentIndex = store.pages.firstIndex(where: { $0.id == id })
        store.delete(id: id)
        if let currentIndex, !store.pages.isEmpty {
            let nextIndex = min(currentIndex, store.pages.count - 1)
            selectedPageID = store.pages[nextIndex].id
        } else {
            selectedPageID = nil
        }
    }
}
