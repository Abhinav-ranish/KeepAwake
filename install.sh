#!/usr/bin/env bash
# One-command installer for KeepAwake.
#   bash install.sh
# Builds the app into ~/Applications, sets it to auto-start, and tells you the
# one optional sudo step for silent lid-closed mode.
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Building app…"
bash build.sh

echo "==> Setting up auto-start (LaunchAgent)…"
PLIST="$HOME/Library/LaunchAgents/local.keepawake.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>local.keepawake</string>
    <key>ProgramArguments</key>
    <array><string>$HOME/Applications/KeepAwake.app/Contents/MacOS/KeepAwake</string></array>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><false/>
    <key>ProcessType</key><string>Interactive</string>
    <key>LimitLoadToSessionType</key><string>Aqua</string>
</dict>
</plist>
EOF
launchctl bootout "gui/$(id -u)/local.keepawake" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null || launchctl load -w "$PLIST"

echo
echo "✅ Installed. Look for the ☕ icon in your menu bar."
echo
echo "OPTIONAL — for silent (no-password) lid-closed mode, run once:"
echo "    sudo bash \"$(pwd)/grant-admin.sh\""
echo "OPTIONAL — Touch ID for sudo prompts:"
echo "    sudo bash \"$(pwd)/enable-touchid-sudo.sh\""
