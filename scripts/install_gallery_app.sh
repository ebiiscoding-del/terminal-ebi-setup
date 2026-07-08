#!/bin/bash
# Installs "Screenshot Gallery.app" into ~/Applications so it's launchable
# from Spotlight (Cmd+Space -> "Screenshot Gallery" -> Enter).
#
# Usage:
#   bash install_gallery_app.sh
#
# Safe to re-run any time (e.g. after moving screenshot_viewer.py) --
# it just regenerates the app bundle.

set -e

APP_NAME="Screenshot Gallery"
APP_DIR="$HOME/Applications/${APP_NAME}.app"
CONTENTS="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS/MacOS"
PORT=5050

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This installer is for macOS only."
    exit 1
fi

if [ ! -f "$HOME/.screenshot_viewer.py" ]; then
    echo "Warning: ~/.screenshot_viewer.py not found."
    echo "Make sure the gallery script is installed there first:"
    echo "  cp scripts/screenshot_viewer.py ~/.screenshot_viewer.py"
    exit 1
fi

mkdir -p "$MACOS_DIR"

cat > "$CONTENTS/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.ebi.screenshotgallery</string>
    <key>CFBundleExecutable</key>
    <string>launcher</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
</dict>
</plist>
PLIST

cat > "$MACOS_DIR/launcher" << LAUNCHER
#!/bin/bash
# Launches the Screenshot Gallery server (if not already running) and opens
# the browser to it. Uses a login shell to pick up your normal PATH (Homebrew
# python etc.), since apps launched via Spotlight/Finder don't inherit your
# interactive shell environment otherwise.

PORT=${PORT}
URL="http://127.0.0.1:\${PORT}"
mkdir -p "\$HOME/.logs"

if ! curl -s -o /dev/null -m 1 "\$URL"; then
    /bin/zsh -l -c "nohup python3 '\$HOME/.screenshot_viewer.py' --port \$PORT --no-browser > '\$HOME/.logs/screenshot_viewer.log' 2>&1 & disown" 2>/dev/null
    for i in 1 2 3 4 5 6 7 8 9 10; do
        sleep 0.5
        if curl -s -o /dev/null -m 1 "\$URL"; then
            break
        fi
    done
fi

open "\$URL"
LAUNCHER

chmod +x "$MACOS_DIR/launcher"

# Nudge Spotlight to index it immediately instead of waiting for its own schedule
touch "$APP_DIR"
mdimport "$APP_DIR" 2>/dev/null || true

echo "Installed: $APP_DIR"
echo ""
echo "Press Cmd+Space, type 'Screenshot Gallery', hit Enter."
echo "(If Spotlight doesn't find it within a minute, open ~/Applications in Finder"
echo " and double-click it once -- that also registers it immediately.)"
