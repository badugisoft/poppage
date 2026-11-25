# Architecture & Module Reference

## Module Map

- `Sources/PopPage/PopPageApp.swift`: `@main` AppKit entry point (`NSApplication` direct launch and main menu setup; avoids SwiftUI `App` lifecycle which opens an empty `Settings` window).
- `Sources/PopPage/AppDelegate.swift`: Management window lifecycle (`NSHostingController`) and `--screenshot-{page,settings,popover}` launch flags.
- `Sources/PopPage/Models/`:
  - `PageItem.swift`: Per-page configuration (`Codable` with defaults for missing keys) and `HTTPHeader`.
  - `PageStore.swift`: `pages.json` persistence and CRUD operations.
- `Sources/PopPage/Services/`:
  - `ImageStore.swift`: Icon/favicon file storage and menu bar resizing.
  - `FaviconFetcher.swift`: Favicon lookup (`<link>` → `/favicon.ico` → Google S2); forwards custom headers only to same-host requests.
  - `LaunchAtLogin.swift`: Login item registration via `SMAppService.mainApp`.
  - `L10n.swift`: Runtime `.lproj` bundle resolution (`LocalizationManager`) and `.appLanguageDidChange` notifications.
  - `SettingsTransfer.swift`: JSON `SettingsBackup` export/import (pages, base64 custom icons, language) with `lastPathComponent` filename sanitization.
- `Sources/PopPage/StatusBar/`:
  - `StatusBarManager.swift`, `PageStatusItem.swift`: `NSStatusItem` and `NSPopover` lifecycle.
- `Sources/PopPage/Popover/`:
  - `PopoverContentViewController.swift`, `WebViewCoordinator.swift`: Bottom toolbar (standard/overlay), `WKWebView`, resize grip, navigation/new-window policies, and local keyboard shortcuts.
- `Sources/PopPage/UI/`:
  - `ManagerView.swift`, `PageEditorView.swift`, `AppSettingsView.swift`, `IconPreview.swift`: Management sidebar, page editor, and Settings tab.

## Key Implementation Notes

- **Persistent WebView State**: `PageStatusItem` owns the `WKWebView` so login and scroll state persist across popover closes; pages reload only when `normalizedURL` changes.
- **Navigation Policy Scope**: `navigationPolicy` applies only to user-triggered main-frame navigations (`.linkActivated`, `.formSubmitted`); initial loads, redirects, back/forward, and reloads are always allowed.
- **Custom HTTP Headers**: Applied via `makeURLRequest(for:)`, main-frame GET interception in `WebViewCoordinator` (with single-shot `pendingHeaderInjectionURL` guard), `webView.customUserAgent` override, and same-host requests in `FaviconFetcher`.
- **Preventing `.transient` Popover Reopen**: `popoverDidClose` records the close timestamp and ignores reopens within `0.3s`.
- **Bottom Toolbar Background**: Observes `themeColor` → `underPageBackgroundColor` via KVO and sets `.aqua`/`.darkAqua` from sRGB luminance. `toolbarOverlayOpacity` controls background alpha when `toolbarOverlay` is enabled.
- **Default vs. Saved (`saved*`) Size & Zoom**: `width`/`height`/`defaultZoom` hold defaults; user-modified values live in `savedWidth`/`savedHeight`/`savedZoom`. When `toolbarOverlay` is `false`, `31pt` is added for the toolbar.
- **Editor `.id(selectedID)`**: `ManagerView` attaches `.id(selectedID)` to `PageEditorView` so switching pages does not trigger `.onChange` and clear `saved*` values.
- **Popover Keyboard Shortcuts**: Local `NSEvent` keyDown monitor scoped to `event.window === view.window` handles `⌘+`/`⌘-`/`⌘0`/`⌘[`/`⌘]`/`⌘R` when `enableKeyboardShortcuts` is enabled.
