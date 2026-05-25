#!/bin/bash
set -e

APP_NAME="FastNote"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Build release
swift build -c release

# Create .app bundle
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy binary
cp "$BUILD_DIR/$APP_NAME" "$MACOS/"

# Copy Info.plist
cp "FastNote/Info.plist" "$CONTENTS/"

# Copy app icon
cp "fastnote.icns" "$RESOURCES/fastnote.icns"

# Copy localization files
for lproj in FastNote/Resources/*.lproj; do
    cp -r "$lproj" "$RESOURCES/"
done

echo "✅ Built $APP_BUNDLE"
echo "Run with: open $APP_BUNDLE"
