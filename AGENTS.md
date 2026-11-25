# AGENTS.md

## Overview

PopPage is a Swift menu bar app for macOS 14+ (`Package.swift`, `swift-tools-version: 6.0`, Swift 5 language mode), built 100% with Antigravity.

## Repository Layout

- `Sources/PopPage/`: AppKit/SwiftUI application source (see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for module details and design notes)
- `Resources/`: `Info.plist`, `AppIcon.icns`, and `Localization/{en,ko,zh-Hans,ja,es,de,fr,tlh}.lproj/Localizable.strings`
- `scripts/` & `Makefile`: Build, `.app` assembly, icon generation, and screenshot capture (run `make help` or see [README.md](README.md))
- `.github/workflows/`: `release.yml` (signed/notarized Apple Silicon `.dmg`/`.zip` on `v*` tags) and `pages.yml` (deploys `site/` on `main`)
- `.agents/skills/`: Project workflows — `commit-and-push`, `release`, and `update-screenshots`
- `site/`: Multilingual GitHub Pages landing page
- `docs/`: Localized READMEs (`README.*.md`), `ARCHITECTURE.md`, and `images/*.png`

## Conventions & Rules

- **Build & Lint**: Run `make lint && make build` before committing code or resource changes.
- **Install & Launch After Edits**: After modifying application code or resources, always run `make install && open /Applications/PopPage.app` so the updated app is installed and running for immediate testing.
- **Language**: Write all developer-facing docs (`AGENTS.md`, `docs/ARCHITECTURE.md`) and code comments in English; keep `en` as the default app/doc language.
- **Docs Sync**: Always update `README.md`, `docs/README.*.md`, `CHANGELOG.md` (`[Unreleased]`), `AGENTS.md`, and `docs/ARCHITECTURE.md` when features, fixes, or structure change.
