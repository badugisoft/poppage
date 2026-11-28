import AppKit
import Combine
import Foundation

@MainActor
final class StatusBarManager: ObservableObject {
    static let shared = StatusBarManager()

    private var items: [UUID: PageStatusItem] = [:]
    private var cancellables = Set<AnyCancellable>()
    private weak var store: PageStore?

    var onOpenManager: (() -> Void)?

    private init() {}

    func start(with store: PageStore) {
        self.store = store
        cancellables.removeAll()

        store.$pages
            .receive(on: RunLoop.main)
            .sink { [weak self] pages in
                self?.sync(pages: pages)
            }
            .store(in: &cancellables)

        sync(pages: store.pages)
    }

    private func sync(pages: [PageItem]) {
        let enabledPages = pages.filter(\.isEnabled)
        let enabledIDs = Set(enabledPages.map(\.id))

        for (id, item) in items where !enabledIDs.contains(id) {
            item.invalidate()
            items.removeValue(forKey: id)
        }

        for page in enabledPages {
            if let existing = items[page.id] {
                existing.apply(page: page)
            } else {
                let item = PageStatusItem(page: page)
                item.onWillOpen = { [weak self] openingID in
                    self?.closeAllPopovers(except: openingID)
                }
                item.onOpenManager = { [weak self] in
                    self?.onOpenManager?()
                }
                item.onSizeChanged = { [weak self] id, newSize in
                    self?.updatePageSize(id: id, size: newSize)
                }
                item.onZoomSaved = { [weak self] id, zoom in
                    self?.updatePageZoom(id: id, zoom: zoom)
                }
                items[page.id] = item
            }
        }
    }

    func closeAllPopovers(except excludedID: UUID? = nil) {
        for (id, item) in items where id != excludedID {
            item.closePopover()
        }
    }

    func openPopover(for pageID: UUID) {
        guard let item = items[pageID] else { return }
        item.openPopover()
    }

    func refreshFavicon(for pageID: UUID) {
        items[pageID]?.refreshFavicon()
    }

    func reload(for pageID: UUID) {
        items[pageID]?.reload()
    }

    func reloadAll() {
        for item in items.values {
            item.reload()
        }
    }

    private func updatePageSize(id: UUID, size: NSSize) {
        guard let store, var page = store.page(for: id) else { return }
        let w = Double(round(size.width))
        let h = Double(round(size.height))
        guard page.savedWidth != w || page.savedHeight != h else { return }
        page.savedWidth = w
        page.savedHeight = h
        store.update(page)
    }

    private func updatePageZoom(id: UUID, zoom: Double) {
        guard let store, var page = store.page(for: id) else { return }
        let rounded = (zoom * 100).rounded() / 100
        guard page.savedZoom != rounded else { return }
        page.savedZoom = rounded
        store.update(page)
    }
}
