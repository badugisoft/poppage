---
name: update-screenshots
description: Capture and update PopPage UI screenshots (page settings, app settings, and popover) using local mock data and verify them visually.
---

# Update PopPage Screenshots

Use this skill whenever the PopPage UI changes or when documentation/GitHub Pages screenshots need to be refreshed.

## Prerequisites

- macOS with Screen Recording permission granted to the terminal/agent host (for `screencapture -l`).
- Swift toolchain (`make app`) and `python3` available.

## Procedure

1. Run the automated screenshot script:
   ```bash
   chmod +x scripts/update-screenshots.sh
   ./scripts/update-screenshots.sh
   ```
   This script automatically:
   - Backs up any existing `~/Library/Application Support/PopPage` and `com.badugisoft.poppage.plist` data and restores them on exit.
   - Builds `build/PopPage.app` in release mode.
   - Starts a local mock HTTP server (`PulseBoard`) so no external network or real user URLs appear in screenshots.
   - Launches `PopPage` with `--screenshot-page`, `--screenshot-settings`, and `--screenshot-popover` in English (`en`).
   - Captures:
     - `docs/images/screenshot-page-settings.png`
     - `docs/images/screenshot-app-settings.png`
     - `docs/images/screenshot-popover.png`

2. Inspect all three generated PNGs (`read_file`) to confirm:
   - Text is crisp and in English.
   - No personal data or real URLs appear.
   - Popover content rendered cleanly without blank frames.

3. Ensure `README.md`, `docs/README.*.md`, and `site/` reference these three files under `docs/images/` (and `site/assets/` if copied for GitHub Pages — if `site/` uses its own copy, sync them).
