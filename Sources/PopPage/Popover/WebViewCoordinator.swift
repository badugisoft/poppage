import AppKit
import Foundation
import WebKit

@MainActor
final class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    var page: PageItem
    private var pendingHeaderInjectionURL: String?

    init(page: PageItem) {
        self.page = page
        super.init()
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let scheme = url.scheme?.lowercased() ?? ""
        if !["http", "https", "about", "data", "blob"].contains(scheme) {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // New window requests (e.g. target="_blank")
        if navigationAction.targetFrame == nil {
            if page.allowNewWindows {
                NSWorkspace.shared.open(url)
            }
            decisionHandler(.cancel)
            return
        }

        // Apply navigation policy only to main-frame link clicks and form submissions
        if let targetFrame = navigationAction.targetFrame,
           targetFrame.isMainFrame,
           navigationAction.navigationType == .linkActivated || navigationAction.navigationType == .formSubmitted {
            switch page.navigationPolicy {
            case .block:
                decisionHandler(.cancel)
                return
            case .openExternal:
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            case .inPlace:
                break
            }
        }

        // Inject custom HTTP/HTTPS headers on main-frame GET navigations if missing
        if let targetFrame = navigationAction.targetFrame,
           targetFrame.isMainFrame,
           scheme == "http" || scheme == "https" {
            let method = navigationAction.request.httpMethod?.uppercased() ?? "GET"
            let nonUAHeaders = page.effectiveHTTPHeaders.filter {
                $0.name.caseInsensitiveCompare("user-agent") != .orderedSame
            }
            if method == "GET", !nonUAHeaders.isEmpty {
                if pendingHeaderInjectionURL == url.absoluteString {
                    pendingHeaderInjectionURL = nil
                    decisionHandler(.allow)
                    return
                }
                let missingOrDifferent = nonUAHeaders.contains { header in
                    navigationAction.request.value(forHTTPHeaderField: header.name) != header.value
                }
                if missingOrDifferent {
                    var modified = navigationAction.request
                    for header in page.effectiveHTTPHeaders {
                        modified.setValue(header.value, forHTTPHeaderField: header.name)
                    }
                    pendingHeaderInjectionURL = url.absoluteString
                    decisionHandler(.cancel)
                    webView.load(modified)
                    return
                }
            }
        }

        decisionHandler(.allow)
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if let url = navigationAction.request.url, page.allowNewWindows {
            NSWorkspace.shared.open(url)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error, in: webView)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleLoadError(error, in: webView)
    }

    private func handleLoadError(_ error: Error, in webView: WKWebView) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }

        let escapedMessage = error.localizedDescription
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        let title = L10n.tr("webview.loadErrorTitle", default: "Unable to load page")
        let html = """
        <!doctype html>
        <html>
        <head>
        <meta charset="utf-8">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            display: flex; align-items: center; justify-content: center;
            height: 100vh; margin: 0; padding: 24px; box-sizing: border-box;
            color: #555; background: #fafafa; text-align: center;
          }
          @media (prefers-color-scheme: dark) {
            body { background: #1e1e1e; color: #ccc; }
          }
          .box { max-width: 320px; }
          h3 { margin: 0 0 8px; font-size: 15px; }
          p { margin: 0; font-size: 12px; opacity: 0.8; word-break: break-word; }
        </style>
        </head>
        <body>
          <div class="box">
            <h3>\(title)</h3>
            <p>\(escapedMessage)</p>
          </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
