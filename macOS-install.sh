#!/bin/bash

set -e  # Stop on error

REPO_URL="https://github.com/nzc0der/startup-dash.git"
BRANCH="feature/native-startup-dashboard-2596268292904286694"
PROJECT_DIR="$HOME/StartupDashboard"
APP_NAME="StartupDashboard.app"

echo "🚀 Starting fresh install..."

# -----------------------------
# 1. Remove old install
# -----------------------------
echo "🧹 Removing old installs..."

rm -rf "$PROJECT_DIR"
sudo rm -rf "/Applications/$APP_NAME"

# -----------------------------
# 2. Clone repo
# -----------------------------
echo "📦 Cloning repository..."

git clone "$REPO_URL" "$PROJECT_DIR"
cd "$PROJECT_DIR"

git checkout "$BRANCH"
git pull

# -----------------------------
# 3. Clean previous builds
# -----------------------------
echo "🧼 Cleaning build artifacts..."

rm -rf .build

# -----------------------------
# 4. Build release
# -----------------------------
echo "🔨 Building release..."

swift build -c release

# -----------------------------
# 5. Create .app bundle
# -----------------------------
echo "📦 Creating app bundle..."

BUILD_PATH=".build/release/StartupDashboard"

if [ ! -f "$BUILD_PATH" ]; then
    echo "❌ Build failed: executable not found."
    exit 1
fi

mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

cp "$BUILD_PATH" "$APP_NAME/Contents/MacOS/StartupDashboard"

cat > "$APP_NAME/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>StartupDashboard</string>
    <key>CFBundleExecutable</key>
    <string>StartupDashboard</string>
    <key>CFBundleIdentifier</key>
    <string>com.startupdashboard.app</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>icon.icns</string>
</dict>
</plist>
EOF

# Find any PNG in UI/Logo and convert to ICNS
ICON_PNG=$(find "macOS/StartupDashboard/UI/Logo" -name "*.png" | head -n 1)
if [ -n "$ICON_PNG" ]; then
    echo "🎨 Converting Logo into Apple ICNS format..."
    
    # Create an iconset structure
    mkdir -p "temp.iconset"
    sips -z 16 16     "$ICON_PNG" --out temp.iconset/icon_16x16.png > /dev/null
    sips -z 32 32     "$ICON_PNG" --out temp.iconset/icon_16x16@2x.png > /dev/null
    sips -z 32 32     "$ICON_PNG" --out temp.iconset/icon_32x32.png > /dev/null
    sips -z 64 64     "$ICON_PNG" --out temp.iconset/icon_32x32@2x.png > /dev/null
    sips -z 128 128   "$ICON_PNG" --out temp.iconset/icon_128x128.png > /dev/null
    sips -z 256 256   "$ICON_PNG" --out temp.iconset/icon_128x128@2x.png > /dev/null
    sips -z 256 256   "$ICON_PNG" --out temp.iconset/icon_256x256.png > /dev/null
    sips -z 512 512   "$ICON_PNG" --out temp.iconset/icon_256x256@2x.png > /dev/null
    sips -z 512 512   "$ICON_PNG" --out temp.iconset/icon_512x512.png > /dev/null
    sips -z 1024 1024 "$ICON_PNG" --out temp.iconset/icon_512x512@2x.png > /dev/null
    
    # Compile the iconset into an .icns file
    iconutil -c icns temp.iconset -o "$APP_NAME/Contents/Resources/icon.icns"
    rm -r "temp.iconset"
fi

# -----------------------------
# 6. Move to Applications
# -----------------------------
echo "📂 Installing to /Applications..."

sudo mv "$APP_NAME" /Applications/

# -----------------------------
# 7. Done
# -----------------------------
echo ""
echo "✅ Installation Complete!"
echo "👉 Open it from Applications."
echo ""
