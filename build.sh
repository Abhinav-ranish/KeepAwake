#!/usr/bin/env bash
# Builds KeepAwake.app into ~/Applications (no admin, no Apple ID).
set -euo pipefail
cd "$(dirname "$0")"

APP="$HOME/Applications/KeepAwake.app"
MACOS="$APP/Contents/MacOS"
RES="$APP/Contents/Resources"

echo "==> Compiling…"
rm -rf "$APP"
mkdir -p "$MACOS" "$RES"
swiftc -O src/main.swift -o "$MACOS/KeepAwake" -framework Cocoa

echo "==> Writing Info.plist…"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>KeepAwake</string>
    <key>CFBundleDisplayName</key>     <string>KeepAwake</string>
    <key>CFBundleIdentifier</key>      <string>local.keepawake</string>
    <key>CFBundleVersion</key>         <string>1.0</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleExecutable</key>      <string>KeepAwake</string>
    <key>CFBundleIconFile</key>        <string>AppIcon</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>LSMinimumSystemVersion</key>  <string>13.0</string>
    <key>LSUIElement</key>             <true/>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
</dict>
</plist>
PLIST

echo "==> Adding icon…"
[ -f AppIcon.icns ] && cp AppIcon.icns "$RES/AppIcon.icns" || echo "   (no AppIcon.icns — run: swift make-icon.swift && iconutil -c icns icon.iconset -o AppIcon.icns)"

echo "==> Code signing…"
if security find-identity -p codesigning 2>/dev/null | grep -q '"abhinav"' \
   || security find-certificate -c abhinav >/dev/null 2>&1; then
    codesign --force --deep --sign "abhinav" "$APP" && echo "   signed as 'abhinav'"
else
    codesign --force --deep --sign - "$APP" 2>/dev/null && echo "   ad-hoc signed"
fi

echo "==> Done: $APP"
