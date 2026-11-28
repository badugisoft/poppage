import SwiftUI

struct WebsiteDataSelectionToggles: View {
    @Binding var selection: WebsiteDataSelection

    var body: some View {
        HStack(spacing: 16) {
            Toggle(L10n.tr("websiteData.cookies", default: "Cookies"), isOn: $selection.cookies)
                .toggleStyle(.checkbox)
            Toggle(L10n.tr("websiteData.storage", default: "Storage"), isOn: $selection.storage)
                .toggleStyle(.checkbox)
            Toggle(L10n.tr("websiteData.cache", default: "Cache"), isOn: $selection.cache)
                .toggleStyle(.checkbox)
            Spacer()
        }
    }
}
