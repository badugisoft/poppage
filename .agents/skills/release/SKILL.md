---
name: release
description: Changelog-driven release workflow for PopPage, including version bump, changelog compare links, signed/notarized GitHub Actions build, and user confirmation.
---

# Release Workflow

Follow this workflow when preparing and publishing a new PopPage release.

## 1. Pre-flight Checks

1. Sync with remote:
   ```bash
   git fetch && git status -sb
   ```
   Ensure `main` is clean and up to date with `origin/main`.
2. Run validation:
   ```bash
   make lint && make build
   ```
3. Check the current version in `Resources/Info.plist` (`CFBundleShortVersionString`) and existing tags (`git tag --sort=-v:refname`).

## 2. Update Changelog & Version

1. Determine the new SemVer version `X.Y.Z` (tag `vX.Y.Z`).
2. Update `Resources/Info.plist`:
   - `CFBundleShortVersionString` -> `X.Y.Z`
   - Increment `CFBundleVersion` if needed.
3. Update `CHANGELOG.md`:
   - Move items from `## [Unreleased]` into `## [X.Y.Z] - YYYY-MM-DD`.
   - Keep `## [Unreleased]` empty at the top.
   - Update bottom comparison links:
     - `[Unreleased]: https://github.com/badugisoft/poppage/compare/vX.Y.Z...HEAD`
     - `[X.Y.Z]: https://github.com/badugisoft/poppage/compare/vPREV...vX.Y.Z` (or `.../releases/tag/v0.1.0` for the initial release).

## 3. Verify Required GitHub Secrets

The `.github/workflows/release.yml` workflow requires these repository secrets:
- `MACOS_CERTIFICATE` (Base64-encoded `.p12`)
- `MACOS_CERTIFICATE_PWD`
- `MACOS_SIGN_IDENTITY` (`Developer ID Application: IN KYU PARK (8GRZ9W9L94)`)
- `APPLE_ID` (`badugiss@badugisoft.net`)
- `APPLE_TEAM_ID` (`8GRZ9W9L94`)
- `APPLE_APP_PASSWORD`

## 4. User Confirmation (Mandatory)

Per repository rules, **always ask the user for explicit confirmation** before committing, tagging, or pushing:
- Show the version (`vX.Y.Z`), `CHANGELOG.md` entry, and compare link.

## 5. Tag & Publish

After user approval:
```bash
git add Resources/Info.plist CHANGELOG.md
git commit -m "chore(release): prepare vX.Y.Z"
git push origin main
git tag -a "vX.Y.Z" -m "Release vX.Y.Z"
git push origin "vX.Y.Z"
```
GitHub Actions (`.github/workflows/release.yml`) will automatically build an Apple Silicon `.app`, codesign, notarize, package `.dmg` and `.zip`, extract notes + compare link from `CHANGELOG.md`, and publish the GitHub Release.
