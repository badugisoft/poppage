import AppKit
import Foundation

@MainActor
final class FaviconFetcher {
    static let shared = FaviconFetcher()

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8
        config.timeoutIntervalForResource = 12
        session = URLSession(configuration: config)
    }

    func fetchFavicon(
        for pageURL: URL,
        pageID: UUID,
        headers: [(name: String, value: String)] = []
    ) async -> NSImage? {
        var candidates: [URL] = []

        if let htmlLinks = await extractIconLinks(from: pageURL, headers: headers) {
            candidates.append(contentsOf: htmlLinks)
        }

        if let scheme = pageURL.scheme, let host = pageURL.host {
            if let rootFavicon = URL(string: "\(scheme)://\(host)/favicon.ico") {
                candidates.append(rootFavicon)
            }
            if let encodedHost = host.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let googleFavicon = URL(string: "https://www.google.com/s2/favicons?domain=\(encodedHost)&sz=64") {
                candidates.append(googleFavicon)
            }
        }

        let targetHost = pageURL.host?.lowercased()
        var seen = Set<String>()
        for candidate in candidates {
            let key = candidate.absoluteString
            guard !seen.contains(key) else { continue }
            seen.insert(key)

            let sameHostHeaders = (candidate.host?.lowercased() == targetHost) ? headers : []
            if let image = await downloadImage(from: candidate, headers: sameHostHeaders) {
                _ = ImageStore.shared.saveFaviconImage(image, pageID: pageID)
                return image
            }
        }

        return nil
    }

    private func extractIconLinks(from pageURL: URL, headers: [(name: String, value: String)]) async -> [URL]? {
        var request = URLRequest(url: pageURL)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }

        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              (200..<400).contains(httpResponse.statusCode),
              let html = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
            return nil
        }

        let baseURL = httpResponse.url ?? pageURL
        let linkTags = matches(for: #"<link\b[^>]*>"#, in: html)
        var results: [URL] = []

        for tag in linkTags {
            let relValue = firstCapture(for: #"rel\s*=\s*["']([^"']+)["']"#, in: tag)?.lowercased() ?? ""
            let isIcon = relValue.contains("icon") || relValue.contains("apple-touch-icon")
            guard isIcon else { continue }

            if let href = firstCapture(for: #"href\s*=\s*["']([^"']+)["']"#, in: tag),
               let resolved = URL(string: href, relativeTo: baseURL)?.absoluteURL {
                results.append(resolved)
            }
        }

        return results
    }

    private func downloadImage(from url: URL, headers: [(name: String, value: String)]) async -> NSImage? {
        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15",
            forHTTPHeaderField: "User-Agent"
        )
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
        guard let (data, response) = try? await session.data(for: request),
              let httpResponse = response as? HTTPURLResponse,
              (200..<400).contains(httpResponse.statusCode),
              !data.isEmpty,
              let image = NSImage(data: data),
              image.size.width > 0,
              image.size.height > 0 else {
            return nil
        }
        return image
    }

    private func matches(for pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            Range(match.range, in: text).map { String(text[$0]) }
        }
    }

    private func firstCapture(for pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text) else {
            return nil
        }
        return String(text[captureRange])
    }
}
