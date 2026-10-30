#!/bin/bash
# Builds DnbCal.app without Xcode: swift build + manual bundle assembly + ad-hoc codesign.
# Usage: scripts/build-app.sh [version]
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-0.0.0}"
APP_NAME="DnbCal"
BUNDLE="build/${APP_NAME}.app"

echo "Building ${APP_NAME} ${VERSION}..."
swift build -c release

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"

cp ".build/release/${APP_NAME}" "$BUNDLE/Contents/MacOS/${APP_NAME}"
cp Resources/AppIcon.icns "$BUNDLE/Contents/Resources/"

PLIST="$BUNDLE/Contents/Info.plist"
cp Resources/Info.plist "$PLIST"
# PlistBuddy fails loudly on a typo key; sed would no-op silently
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "$PLIST"

echo "Signing (ad-hoc)..."
codesign --force --sign - "$BUNDLE"

echo "Built: $BUNDLE"
codesign -dv "$BUNDLE"
