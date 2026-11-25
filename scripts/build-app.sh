#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "Building PopPage (release)..."
swift build -c release

APP_DIR="build/PopPage.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"

cp ".build/release/PopPage" "$APP_DIR/Contents/MacOS/PopPage"
cp "Resources/Info.plist" "$APP_DIR/Contents/Info.plist"
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi
cp -R Resources/Localization/*.lproj "$APP_DIR/Contents/Resources/"

codesign --force --sign - "$APP_DIR"
echo "Built $APP_DIR"
