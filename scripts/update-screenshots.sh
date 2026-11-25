#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="$ROOT_DIR/docs/images"
mkdir -p "$OUT_DIR"

APP_SUPPORT_DIR="$HOME/Library/Application Support/PopPage"
PREFS_PLIST="$HOME/Library/Preferences/com.badugisoft.poppage.plist"
BACKUP_DIR="$(mktemp -d)"
MOCK_DIR="$(mktemp -d)"
SERVER_PID=""
APP_PID=""

cleanup() {
    if [ -n "$APP_PID" ]; then
        kill "$APP_PID" 2>/dev/null || true
        wait "$APP_PID" 2>/dev/null || true
    fi
    pkill -x PopPage 2>/dev/null || true
    if [ -n "$SERVER_PID" ]; then
        kill "$SERVER_PID" 2>/dev/null || true
    fi
    rm -rf "$APP_SUPPORT_DIR"
    if [ -d "$BACKUP_DIR/PopPage" ]; then
        mkdir -p "$(dirname "$APP_SUPPORT_DIR")"
        cp -R "$BACKUP_DIR/PopPage" "$APP_SUPPORT_DIR"
    fi
    if [ -f "$BACKUP_DIR/prefs.plist" ]; then
        cp "$BACKUP_DIR/prefs.plist" "$PREFS_PLIST"
    else
        rm -f "$PREFS_PLIST"
    fi
    defaults read com.badugisoft.poppage >/dev/null 2>&1 || true
    rm -rf "$BACKUP_DIR" "$MOCK_DIR"
}
trap cleanup EXIT

echo "Backing up existing PopPage data..."
if [ -d "$APP_SUPPORT_DIR" ]; then
    cp -R "$APP_SUPPORT_DIR" "$BACKUP_DIR/PopPage"
fi
if [ -f "$PREFS_PLIST" ]; then
    cp "$PREFS_PLIST" "$BACKUP_DIR/prefs.plist"
fi

echo "Building PopPage.app..."
./scripts/build-app.sh

echo "Starting local mock web server..."
cat > "$MOCK_DIR/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="theme-color" content="#0f172a" />
  <title>PulseBoard — Daily Workspace</title>
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect width='64' height='64' rx='16' fill='%232563eb'/><path d='M18 34l9 9 19-21' stroke='white' stroke-width='6' fill='none' stroke-linecap='round' stroke-linejoin='round'/></svg>">
  <style>
    :root {
      color-scheme: dark;
      --bg: #0f172a;
      --card: #1e293b;
      --border: #334155;
      --text: #f8fafc;
      --muted: #94a3b8;
      --accent: #38bdf8;
      --green: #34d399;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
      background: var(--bg);
      color: var(--text);
      padding: 18px;
      line-height: 1.45;
    }
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .brand { font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 8px; }
    .dot { width: 10px; height: 10px; border-radius: 50%; background: var(--green); }
    .badge {
      font-size: 11px;
      padding: 3px 8px;
      border-radius: 999px;
      background: rgba(56, 189, 248, 0.15);
      color: var(--accent);
      font-weight: 600;
    }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-bottom: 14px;
    }
    .stat {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 12px;
    }
    .stat-label { font-size: 11px; color: var(--muted); }
    .stat-val { font-size: 20px; font-weight: 700; margin-top: 4px; }
    .card {
      background: var(--card);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 14px;
      margin-bottom: 12px;
    }
    .card-title { font-size: 13px; font-weight: 600; margin-bottom: 10px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; }
    .task {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid rgba(51, 65, 85, 0.6);
      font-size: 13px;
    }
    .task:last-child { border-bottom: none; padding-bottom: 0; }
    .pill { font-size: 11px; color: var(--green); }
    .pill.pending { color: var(--accent); }
    .note { font-size: 13px; color: #cbd5e1; }
  </style>
</head>
<body>
  <header>
    <div class="brand"><span class="dot"></span> PulseBoard</div>
    <span class="badge">Live Sync</span>
  </header>
  <div class="grid">
    <div class="stat">
      <div class="stat-label">Open Tasks</div>
      <div class="stat-val">4</div>
    </div>
    <div class="stat">
      <div class="stat-label">Focus Time</div>
      <div class="stat-val">2h 40m</div>
    </div>
  </div>
  <div class="card">
    <div class="card-title">Today's Checklist</div>
    <div class="task"><span>Review v0.1.0 release notes</span><span class="pill">Done</span></div>
    <div class="task"><span>Check CI notarization workflow</span><span class="pill pending">In Progress</span></div>
    <div class="task"><span>Update multilingual docs</span><span class="pill">Done</span></div>
    <div class="task"><span>Prepare demo screenshots</span><span class="pill pending">Active</span></div>
  </div>
  <div class="card">
    <div class="card-title">Quick Scratchpad</div>
    <p class="note">Pinned in the menu bar for instant access without switching spaces or browser tabs.</p>
  </div>
</body>
</html>
HTML

python3 - "$MOCK_DIR" >/tmp/poppage-mock-server.log 2>&1 <<'PY' &
import functools, http.server, os, sys
directory = sys.argv[1]
handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=directory)
server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
with open(os.path.join(directory, "port"), "w") as f:
    f.write(str(server.server_port))
server.serve_forever()
PY
SERVER_PID=$!
for _ in $(seq 1 30); do
    if [ -s "$MOCK_DIR/port" ]; then
        break
    fi
    sleep 0.1
done
PORT="$(cat "$MOCK_DIR/port")"
MOCK_URL="http://127.0.0.1:${PORT}/index.html"
echo "Mock server running at $MOCK_URL"

echo "Seeding mock PopPage configuration..."
rm -rf "$APP_SUPPORT_DIR"
mkdir -p "$APP_SUPPORT_DIR/icons"
defaults write com.badugisoft.poppage appLanguage -string "en"

cat > "$APP_SUPPORT_DIR/pages.json" <<JSON
[
  {
    "allowNewWindows": true,
    "animated": true,
    "closeOnFocusLoss": true,
    "customHeaders": [
      {
        "id": "11111111-1111-1111-1111-111111111111",
        "isEnabled": true,
        "name": "X-Workspace",
        "value": "demo-team"
      }
    ],
    "customText": "PB",
    "defaultZoom": 1.0,
    "enableKeyboardShortcuts": true,
    "height": 540,
    "iconType": "text",
    "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
    "imageIsTemplate": false,
    "isEnabled": true,
    "name": "PulseBoard",
    "navigationPolicy": "inPlace",
    "rememberSize": true,
    "rememberZoom": true,
    "resizable": true,
    "showBackForwardButtons": true,
    "showReloadButton": true,
    "showZoomButtons": true,
    "toolbarOverlay": false,
    "toolbarOverlayOpacity": 0.85,
    "urlString": "$MOCK_URL",
    "width": 380
  },
  {
    "allowNewWindows": true,
    "animated": true,
    "closeOnFocusLoss": true,
    "customHeaders": [],
    "customText": "Docs",
    "defaultZoom": 1.0,
    "enableKeyboardShortcuts": true,
    "height": 600,
    "iconType": "text",
    "id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
    "imageIsTemplate": false,
    "isEnabled": true,
    "name": "API Reference",
    "navigationPolicy": "openExternal",
    "rememberSize": true,
    "rememberZoom": true,
    "resizable": true,
    "showBackForwardButtons": true,
    "showReloadButton": true,
    "showZoomButtons": true,
    "toolbarOverlay": false,
    "toolbarOverlayOpacity": 0.85,
    "urlString": "https://docs.example.com",
    "width": 420
  },
  {
    "allowNewWindows": false,
    "animated": true,
    "closeOnFocusLoss": true,
    "customHeaders": [],
    "customText": "CI",
    "defaultZoom": 0.9,
    "enableKeyboardShortcuts": true,
    "height": 520,
    "iconType": "text",
    "id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
    "imageIsTemplate": false,
    "isEnabled": false,
    "name": "Build Status",
    "navigationPolicy": "block",
    "rememberSize": true,
    "rememberZoom": true,
    "resizable": true,
    "showBackForwardButtons": false,
    "showReloadButton": true,
    "showZoomButtons": true,
    "toolbarOverlay": true,
    "toolbarOverlayOpacity": 0.85,
    "urlString": "https://status.example.com",
    "width": 380
  }
]
JSON

find_window_id() {
    local pid="$1"
    local mode="$2"
    swift -e '
import CoreGraphics
import Foundation

let targetPID = Int32(CommandLine.arguments[1])!
let mode = CommandLine.arguments[2]
let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
    exit(1)
}
var bestID: Int?
var bestArea: Double = 0
for win in list {
    guard let ownerPID = win[kCGWindowOwnerPID as String] as? Int32, ownerPID == targetPID else { continue }
    guard let bounds = win[kCGWindowBounds as String] as? [String: Any],
          let w = bounds["Width"] as? Double,
          let h = bounds["Height"] as? Double,
          let winID = win[kCGWindowNumber as String] as? Int else { continue }
    if mode == "popover" && w >= 250 && h >= 250 {
        bestID = winID
        break
    }
    let area = w * h
    if w >= 400 && h >= 300 && area > bestArea {
        bestArea = area
        bestID = winID
    }
}
if let id = bestID {
    print(id)
    exit(0)
}
exit(1)
' "$pid" "$mode"
}

capture_mode() {
    local flag="$1"
    local mode="$2"
    local out_file="$3"

    pkill -x PopPage 2>/dev/null || true
    sleep 0.3

    "$ROOT_DIR/build/PopPage.app/Contents/MacOS/PopPage" "$flag" &
    APP_PID=$!

    local win_id=""
    for _ in $(seq 1 30); do
        if win_id="$(find_window_id "$APP_PID" "$mode" 2>/dev/null)"; then
            break
        fi
        sleep 0.25
    done

    if [ -z "$win_id" ]; then
        echo "Failed to find window for $flag" >&2
        exit 1
    fi

    # Wait briefly for WebKit/SwiftUI rendering to settle
    sleep 1.2
    screencapture -x -l "$win_id" "$out_file"
    echo "Captured $out_file (window $win_id)"

    kill "$APP_PID" 2>/dev/null || true
    wait "$APP_PID" 2>/dev/null || true
    APP_PID=""
}

capture_mode "--screenshot-page" "window" "$OUT_DIR/screenshot-page-settings.png"
capture_mode "--screenshot-settings" "window" "$OUT_DIR/screenshot-app-settings.png"
capture_mode "--screenshot-popover" "popover" "$OUT_DIR/screenshot-popover.png"

echo "All screenshots updated in $OUT_DIR"
