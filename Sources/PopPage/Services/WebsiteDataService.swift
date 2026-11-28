import Foundation
import WebKit

struct WebsiteDataSelection: Equatable, Sendable {
    var cookies: Bool = true
    var storage: Bool = true
    var cache: Bool = true

    var isEmpty: Bool {
        !cookies && !storage && !cache
    }

    var isAllSelected: Bool {
        cookies && storage && cache
    }

    var dataTypes: Set<String> {
        if isAllSelected {
            return WKWebsiteDataStore.allWebsiteDataTypes()
        }

        var types = Set<String>()
        if cookies {
            types.insert(WKWebsiteDataTypeCookies)
        }
        if storage {
            types.formUnion([
                WKWebsiteDataTypeLocalStorage,
                WKWebsiteDataTypeSessionStorage,
                WKWebsiteDataTypeIndexedDBDatabases,
                WKWebsiteDataTypeWebSQLDatabases,
                WKWebsiteDataTypeServiceWorkerRegistrations
            ])
        }
        if cache {
            types.formUnion([
                WKWebsiteDataTypeDiskCache,
                WKWebsiteDataTypeMemoryCache,
                WKWebsiteDataTypeOfflineWebApplicationCache,
                WKWebsiteDataTypeFetchCache
            ])
        }
        return types
    }
}

@MainActor
enum WebsiteDataService {
    /// Clears selected website data types across all domains.
    static func clearAll(selection: WebsiteDataSelection) async {
        let types = selection.dataTypes
        guard !types.isEmpty else { return }
        await WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast)
    }

    /// Clears selected website data types matching the host of the given URL.
    @discardableResult
    static func clearData(for url: URL, selection: WebsiteDataSelection) async -> Int {
        let types = selection.dataTypes
        guard !types.isEmpty,
              let host = url.host?.lowercased(),
              !host.isEmpty else {
            return 0
        }

        let store = WKWebsiteDataStore.default()
        let records = await store.dataRecords(ofTypes: types)
        let matching = records.filter { record in
            matchesHost(host, recordName: record.displayName.lowercased())
        }
        guard !matching.isEmpty else { return 0 }
        await store.removeData(ofTypes: types, for: matching)
        return matching.count
    }

    private static func matchesHost(_ host: String, recordName: String) -> Bool {
        guard !recordName.isEmpty else { return false }
        return host == recordName
            || host.hasSuffix("." + recordName)
            || recordName.hasSuffix("." + host)
    }
}
