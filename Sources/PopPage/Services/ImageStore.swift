import AppKit
import Foundation

@MainActor
final class ImageStore {
    static let shared = ImageStore()

    let baseDirectory: URL
    let iconsDirectory: URL

    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        baseDirectory = appSupport.appendingPathComponent("PopPage", isDirectory: true)
        iconsDirectory = baseDirectory.appendingPathComponent("icons", isDirectory: true)
        try? FileManager.default.createDirectory(at: iconsDirectory, withIntermediateDirectories: true)
    }

    func fileURL(for fileName: String) -> URL {
        iconsDirectory.appendingPathComponent(fileName)
    }

    func loadImage(fileName: String?) -> NSImage? {
        guard let fileName, !fileName.isEmpty else { return nil }
        let url = fileURL(for: fileName)
        return NSImage(contentsOf: url)
    }

    func saveCustomImage(from sourceURL: URL, pageID: UUID) -> String? {
        guard let image = NSImage(contentsOf: sourceURL) else { return nil }
        let fileName = "custom-\(pageID.uuidString).png"
        let destURL = fileURL(for: fileName)

        if let pngData = Self.pngData(from: image) {
            do {
                try pngData.write(to: destURL, options: .atomic)
                return fileName
            } catch {
                return nil
            }
        }

        let ext = sourceURL.pathExtension.isEmpty ? "png" : sourceURL.pathExtension
        let fallbackName = "custom-\(pageID.uuidString).\(ext)"
        let fallbackURL = fileURL(for: fallbackName)
        do {
            if FileManager.default.fileExists(atPath: fallbackURL.path) {
                try FileManager.default.removeItem(at: fallbackURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: fallbackURL)
            return fallbackName
        } catch {
            return nil
        }
    }

    func faviconFileName(for pageID: UUID) -> String {
        "favicon-\(pageID.uuidString).png"
    }

    func saveFaviconImage(_ image: NSImage, pageID: UUID) -> String? {
        guard let pngData = Self.pngData(from: image) else { return nil }
        let fileName = faviconFileName(for: pageID)
        let destURL = fileURL(for: fileName)
        do {
            try pngData.write(to: destURL, options: .atomic)
            return fileName
        } catch {
            return nil
        }
    }

    func loadFavicon(pageID: UUID) -> NSImage? {
        loadImage(fileName: faviconFileName(for: pageID))
    }

    func removeImage(fileName: String?) {
        guard let fileName, !fileName.isEmpty else { return }
        let url = fileURL(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }

    func removeFavicon(pageID: UUID) {
        removeImage(fileName: faviconFileName(for: pageID))
    }

    static func resizeForMenuBar(_ image: NSImage, maxHeight: CGFloat = 18, isTemplate: Bool = false) -> NSImage {
        let originalSize = image.size
        guard originalSize.width > 0, originalSize.height > 0 else { return image }

        let aspect = originalSize.width / originalSize.height
        var targetHeight = maxHeight
        var targetWidth = targetHeight * aspect
        let maxWidth: CGFloat = 36
        if targetWidth > maxWidth {
            targetWidth = maxWidth
            targetHeight = targetWidth / aspect
        }

        let targetSize = NSSize(width: round(targetWidth), height: round(targetHeight))
        let resized = NSImage(size: targetSize, flipped: false) { rect in
            image.draw(in: rect, from: NSRect(origin: .zero, size: originalSize), operation: .sourceOver, fraction: 1.0)
            return true
        }
        resized.isTemplate = isTemplate
        return resized
    }

    private static func pngData(from image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else {
            return nil
        }
        return rep.representation(using: .png, properties: [:])
    }
}
