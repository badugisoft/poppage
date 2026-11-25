# Changelog

All notable changes to **PopPage** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Fixed an issue where a transient popover (`closeOnFocusLoss`) stopped closing on focus loss or outside clicks after interacting with an HTML `<select>` dropdown inside the page

## [0.1.0] - 2026-11-25

### Added
- Native macOS 14+ menu bar app (`NSStatusItem` + `NSPopover` + persistent `WKWebView`)
- Page management window for adding, editing, reordering, and toggling websites
- Menu bar icon customization: automatic favicon fetching, custom text, or custom image (with template mode)
- Per-page popover behavior: focus-loss auto-close, open/close animation, resizable grip, size/zoom persistence
- Navigation & new window policies (`Do Not Navigate`, `Open in External Browser`, `Navigate in Popover`)
- Custom per-page HTTP/HTTPS request headers (including `User-Agent`)
- Bottom toolbar with Back/Forward, Reload, Zoom controls, adaptive background color, and adjustable overlay opacity
- Popover keyboard shortcuts (`⌘+`, `⌘-`, `⌘0`, `⌘[`, `⌘]`, `⌘R`) with quick-reference popover
- App settings: Launch at Login, in-app language switcher, and JSON settings export/import
- 8 localizations: English, Korean, Simplified Chinese, Japanese, Spanish, German, French, and Klingon
- Signed & notarized macOS `.dmg` and `.zip` release packaging

[Unreleased]: https://github.com/badugisoft/poppage/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/badugisoft/poppage/releases/tag/v0.1.0
