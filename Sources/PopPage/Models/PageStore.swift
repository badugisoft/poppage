import Foundation
import SwiftUI

@MainActor
final class PageStore: ObservableObject {
    static let shared = PageStore()

    @Published var pages: [PageItem] = [] {
        didSet {
            if !isLoading {
                save()
            }
        }
    }

    private var isLoading = false
    private let fileURL: URL

    private init() {
        let baseDir = ImageStore.shared.baseDirectory
        try? FileManager.default.createDirectory(at: baseDir, withIntermediateDirectories: true)
        fileURL = baseDir.appendingPathComponent("pages.json")
        load()
    }

    func load() {
        isLoading = true
        defer { isLoading = false }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            pages = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            pages = try decoder.decode([PageItem].self, from: data)
        } catch {
            pages = []
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(pages)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Ignore write errors silently in UI flow
        }
    }

    @discardableResult
    func addNewPage() -> PageItem {
        let item = PageItem()
        pages.append(item)
        return item
    }

    func update(_ page: PageItem) {
        guard let index = pages.firstIndex(where: { $0.id == page.id }) else { return }
        pages[index] = page
    }

    func delete(id: UUID) {
        guard let index = pages.firstIndex(where: { $0.id == id }) else { return }
        let removed = pages.remove(at: index)
        ImageStore.shared.removeImage(fileName: removed.customImageFileName)
        ImageStore.shared.removeFavicon(pageID: removed.id)
    }

    func move(fromOffsets: IndexSet, toOffset: Int) {
        pages.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func page(for id: UUID) -> PageItem? {
        pages.first(where: { $0.id == id })
    }
}
