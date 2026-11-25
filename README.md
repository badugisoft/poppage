English | [한국어](docs/README.ko.md) | [简体中文](docs/README.zh-Hans.md) | [日本語](docs/README.ja.md) | [Español](docs/README.es.md) | [Deutsch](docs/README.de.md) | [Français](docs/README.fr.md) | [tlhIngan Hol](docs/README.tlh.md)

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#requirements)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#requirements)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

A lightweight, Swift-based macOS menu bar application for pinning websites and opening them quickly in a popover.

[Website](https://badugisoft.github.io/poppage/) · [Download Latest](https://github.com/badugisoft/poppage/releases/latest) · [Screenshots](#screenshots) · [Features](#features) · [Shortcuts](#keyboard-shortcuts) · [Changelog](CHANGELOG.md)

## Why PopPage?

There are already many macOS menu bar browser apps—some with far more features—such as **MenubarX**, **FloatBrowser**, and **MenuBox**. PopPage was created out of the need for a **completely free**, **lightweight** native app that focuses strictly on essential features (per-page icon customization, navigation policies, custom HTTP headers, and settings export/import) without unnecessary bloat.

This app was **built 100% with Antigravity**.

## Screenshots

| Popover Window | Page Settings | App Settings |
| :---: | :---: | :---: |
| ![Popover Window](docs/images/screenshot-popover.png) | ![Page Settings](docs/images/screenshot-page-settings.png) | ![App Settings](docs/images/screenshot-app-settings.png) |

## Download & Install

1. Download the latest signed and notarized `.dmg` or `.zip` (Apple Silicon) from [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest).
2. Open the `.dmg` (or extract the `.zip`) and drag **PopPage.app** into `/Applications`.
3. Launch **PopPage** from Applications or Spotlight.

> Intel (`x86_64`) Macs are not included in prebuilt releases; please [build from source](#build-from-source) if needed.

## Features

- **Page Management**: Add, edit, delete, reorder, and enable/disable websites from the management window
- **Menu Bar Icon Customization**: Automatically fetch website favicons, use custom text, or choose a custom image (with template mode support)
- **Popover Toggle & Focus Behavior**: Click a menu bar item to toggle its popover, and optionally close automatically when focus leaves the popover
- **Open/Close Animation**: Per-page toggle for popover animation
- **New Window & Navigation Policies**:
  - Open new window links (`target="_blank"`, etc.) in the default external browser
  - Configure page navigation behavior (`Do Not Navigate` / `Open in External Browser` / `Navigate in Popover`)
- **Custom HTTP Headers**: Add, toggle, and remove per-page HTTP/HTTPS request headers (including `User-Agent`)
- **Popover Size & Resizing**: Set default width/height, resize via the bottom-right grip, and optionally remember modified sizes
- **Zoom Controls**: Set a default zoom level per page and optionally remember modified zoom levels
- **Keyboard Shortcuts**: Toggleable per-page popover shortcuts with a compact shortcut reference popover next to the toggle
- **Bottom Toolbar & Overlay**: Toggle visibility of Back/Forward, Reload, and Zoom buttons, or overlay the toolbar on top of the webpage with adjustable background opacity
- **Adaptive Toolbar Background**: Automatically matches the bottom toolbar color to the webpage background
- **App Settings**: Configure Launch at Login, in-app language (`System Default` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`), and export/import settings (pages, custom icons, and language) as JSON from the Settings tab at the bottom left of the management window
- **Localization**: Supports English (default), Korean, Simplified Chinese, Japanese, Spanish, German, French, and Klingon

## Keyboard Shortcuts

Available inside the popover when **Enable Keyboard Shortcuts** is turned on for the page:

| Shortcut | Action |
| :---: | :--- |
| `⌘ +` | Zoom In |
| `⌘ -` | Zoom Out |
| `⌘ 0` | Reset Zoom |
| `⌘ [` | Back |
| `⌘ ]` | Forward |
| `⌘ R` | Reload |

## Requirements

- macOS 14.0 or later
- Xcode / Swift 6 toolchain (for building from source)

## Build from Source

```bash
# Show all available targets
make help

# Debug / release build
make build
make release

# Build .app bundle (build/PopPage.app)
make app

# Build and launch
make run

# Install to /Applications (or INSTALL_DIR=/custom/path make install)
make install
make uninstall

# Regenerate AppIcon.icns or lint plist/strings
make icon
make lint

# Clean build artifacts
make clean
```

## Data Storage

- Page configuration: `~/Library/Application Support/PopPage/pages.json`
- Cached favicons and custom images: `~/Library/Application Support/PopPage/icons/`
- App language preference: `~/Library/Preferences/com.badugisoft.poppage.plist`
