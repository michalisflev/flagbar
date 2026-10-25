set -e
cd "$(dirname "$0")"

APP=FlagBar.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc -O FlagBar.swift -o "$APP/Contents/MacOS/FlagBar" -framework Cocoa -framework Carbon

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>FlagBar</string>
  <key>CFBundleIdentifier</key><string>gr.michalisflev.flagbar</string>
  <key>CFBundleExecutable</key><string>FlagBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
EOF

echo "Built $APP — run: open $APP"
