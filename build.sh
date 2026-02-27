#!/bin/bash
set -euo pipefail

APP_NAME="Caffeinate UI"
BUNDLE_DIR=".build/release/${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"

echo "Building release..."
swift build -c release

echo "Creating app bundle..."
rm -rf "${BUNDLE_DIR}"
mkdir -p "${MACOS_DIR}" "${CONTENTS_DIR}/Resources"

cp .build/release/CaffeinateUI "${MACOS_DIR}/CaffeinateUI"
cp Resources/Info.plist "${CONTENTS_DIR}/Info.plist"
cp Resources/AppIcon.icns "${CONTENTS_DIR}/Resources/AppIcon.icns"

INSTALL_DIR="/Applications/${APP_NAME}.app"
echo "Installing to ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}"
cp -R "${BUNDLE_DIR}" "${INSTALL_DIR}"

echo "Installed: ${INSTALL_DIR}"
echo "Run with: open \"${INSTALL_DIR}\""
