import AppKit
import SwiftUI

struct IconPreview: View {
    let page: PageItem
    var refreshTrigger: UUID = UUID()

    var body: some View {
        Group {
            switch page.iconType {
            case .favicon:
                if let favicon = ImageStore.shared.loadFavicon(pageID: page.id) {
                    Image(nsImage: favicon)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: "globe")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                }

            case .text:
                let label = page.customText.trimmingCharacters(in: .whitespacesAndNewlines)
                Text(label.isEmpty ? page.name : label)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))

            case .image:
                if let image = ImageStore.shared.loadImage(fileName: page.customImageFileName) {
                    Image(nsImage: image)
                        .resizable()
                        .renderingMode(page.imageIsTemplate ? .template : .original)
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .frame(width: 18, height: 18)
                }
            }
        }
        .id(refreshTrigger)
    }
}
