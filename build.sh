#!/bin/bash
set -e

APP_NAME="FastNote"
BUILD_DIR=".build/release"

if [ "$1" = "dev" ]; then
    BUNDLE_NAME="FastNote Dev"
else
    BUNDLE_NAME="FastNote"
fi

APP_BUNDLE="$BUNDLE_NAME.app"
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
cp "$BUILD_DIR/$APP_NAME" "$MACOS/$APP_NAME"

# Copy and patch Info.plist for dev builds
cp "FastNote/Info.plist" "$CONTENTS/Info.plist"
if [ "$1" = "dev" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleName 'FastNote Dev'" "$CONTENTS/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 'FastNote Dev'" "$CONTENTS/Info.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier 'com.murat.FastNote.dev'" "$CONTENTS/Info.plist"
fi

# Copy app icon
cp "fastnote.icns" "$RESOURCES/fastnote.icns"

# Copy localization files
for lproj in FastNote/Resources/*.lproj; do
    cp -r "$lproj" "$RESOURCES/"
done

echo "✅ Built $APP_BUNDLE"
echo "Run with: open \"$APP_BUNDLE\""
